public with sharing class OnlineStoreCartController {
    public inherited sharing class InvalidInputException extends Exception {}
    
    public static String added = 'Added';
    public static String payment = 'Payment';
    public static String paid = 'Paid';
   	public static String noSuchQuantity = 'There is no such quantity in stock.';

    @AuraEnabled
    public static Integer addToCart(String userId, String productId, Integer quantity) {
        User__c user = [
            SELECT Id, (
                SELECT Quantity__c 
                FROM Carts__r
                WHERE ProductId__c = :productId
                    AND Status__c = :added
            ) 
            FROM User__c 
            WHERE Id = :userId 
            LIMIT 1
        ];
        Product__c product = [SELECT InStock__c FROM Product__c WHERE Id = :productId LIMIT 1];
        List<Cart__c> existingRecords = user.Carts__r;

        Integer cartItemsCount = [SELECT COUNT() FROM Cart__c WHERE UserId__c = :userId AND Status__c = :added];

        if (existingRecords.size() > 0) {
            Cart__c record = existingRecords[0];
            record.Quantity__c += quantity;

            if (record.Quantity__c > product.InStock__c) {
                throw new InvalidInputException(noSuchQuantity);
            }

            update record;
            return cartItemsCount;
        } else {
            if (quantity > product.InStock__c) {
                throw new InvalidInputException(noSuchQuantity);
            }

            insert new Cart__c(
                UserId__c = userId,
                ProductId__c = productId,
                Quantity__c = quantity,
                Status__c = added
            );
            return cartItemsCount + 1;
        }
    }

    @AuraEnabled
    public static Boolean updateQuantity(String userId, String productId, Integer quantity) {
        if (quantity == 0) return removeFromCart(userId, productId);

        Cart__c existingRecord = [
            SELECT Id, Quantity__c, ProductId__r.InStock__c 
            FROM Cart__c 
            WHERE UserId__c = :userId AND ProductId__c = :productId AND Status__c = :added
            LIMIT 1
        ];

        if (quantity > existingRecord.ProductId__r.InStock__c) {
            throw new InvalidInputException(noSuchQuantity);
        }

        existingRecord.Quantity__c = quantity;
        update existingRecord;
        return true;
    }

    @AuraEnabled
    public static Boolean removeFromCart(String userId, String productId) {
        List<Cart__c> existingRecords = [
            SELECT Id FROM Cart__c 
            WHERE UserId__c = :userId AND ProductId__c = :productId AND Status__c = :added
        ];

        if (existingRecords.size() == 0) return false;

        delete existingRecords;
        return true;
    }

    @AuraEnabled
    public static List<Cart__c> getCartUsingStatus(String userId, String status) {
        return [
            SELECT 
                Id, UserId__c, Quantity__c,
                ProductId__r.Id, ProductId__r.Name, ProductId__r.InStock__c, 
                ProductId__r.Image__c, ProductId__r.Price__c
            FROM Cart__c
            WHERE UserId__c = :userId
          		AND Status__c = :status
        ];
    }

    @AuraEnabled
    public static List<Cart__c> getCart(String userId) {
        return getCartUsingStatus(userId, added);
    }

    @AuraEnabled
    public static List<Cart__c> getOrder(String userId) {
        return getCartUsingStatus(userId, payment);
    }

    @AuraEnabled
    public static List<Cart__c> getPaidItems(String userId) {
        return getCartUsingStatus(userId, paid);
    }

    @AuraEnabled
    public static Integer getCartItemsCountUsingStatus(String userId, String status) {
        return [
            SELECT COUNT()
            FROM Cart__c
            WHERE UserId__c = :userId
                  AND Status__c = :status
        ];
    }

    @AuraEnabled
    public static Integer getCartItemsCount(String userId) {
        return getCartItemsCountUsingStatus(userId, added);
    }

    @AuraEnabled
    public static List<Cart__c> createOrder(String userId) {
        return updateCartStatus(userId, added, payment);
    }

    @AuraEnabled
    public static List<Cart__c> removeOrder(String userId) {
        return updateCartStatus(userId, payment, added);
    }

    @AuraEnabled
    public static Boolean payForOrder(String userId) {
        Double bill = calculateBill(userId);

        if (OnlineStoreBankingController.widthdrawFromCard(userId, bill)) {
            updateCartStatus(userId, payment, paid);
            return true;
        }
        
        return false;
    }

    public static Double calculateBill(String userId) {
        List<Cart__c> order = getOrder(userId);

        Double bill = 0;
        for (Cart__c orderItem: order) {
            bill += orderItem.Quantity__c * orderItem.ProductId__r.Price__c;
        }
        return bill;
    }

    public static List<Cart__c> updateCartStatus(String userId, String oldStatus, String newStatus) {
        List<Cart__c> cartItems = [
            SELECT 
                Id, Status__c
            FROM Cart__c
            WHERE UserId__c = :userId
          		AND Status__c = :oldStatus
        ];

        if (oldStatus == newStatus) return cartItems;

        for (Cart__c item : cartItems) {
            item.Status__c = newStatus;
        }

        update cartItems;
        return cartItems;
    }

    public static void updateStatusTrigger(List<Cart__c> newList, Map<Id, Cart__c> oldMap) {
        Boolean updateInStock = false;
        Boolean decrease = false; // is product.InStock__c need to be decreased

        for (Cart__c newItem : newList) {
            Cart__c oldItem = oldMap.get(newItem.Id);

            // nothing to do
            if (newItem.Status__c == oldItem.Status__c) return;

            // from added to payment
            if (oldItem.Status__c == added && newItem.Status__c == payment) {
                updateInStock = true;
                decrease = true;
                break;
            }

            // from payment to added
            if (oldItem.Status__c == payment && newItem.Status__c == added) {
                updateInStock = true;
                decrease = false;
                break;
            }
        }

        if (!updateInStock) return;

        Map<Id, Cart__c> cartItemsWithProducts = new Map<Id, Cart__c>([
            SELECT Id, Quantity__c, ProductId__r.InStock__c 
            FROM Cart__c 
            WHERE Id IN :newList
        ]);
        List<Product__c> productsToUpdate = new List<Product__c>();
        
        for (Id cartItemId : cartItemsWithProducts.keySet()) {
            Cart__c cartItem = cartItemsWithProducts.get(cartItemId);

            if (decrease) cartItem.ProductId__r.InStock__c -= cartItem.Quantity__c;
            // otherwise increase
            if (!decrease) cartItem.ProductId__r.InStock__c += cartItem.Quantity__c;
            
            productsToUpdate.add(cartItem.ProductId__r);
        }

        update productsToUpdate;
    }
}