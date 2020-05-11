public with sharing class OnlineStoreCartController {
    public inherited sharing class InvalidInputException extends Exception {}
    
    public static String added = 'Added';
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
    public static List<Cart__c> getCart(String userId) {
        return getCartUsingStatus(userId, added);
    }

    @AuraEnabled
    public static List<Cart__c> getPaidItems(String userId) {
        return getCartUsingStatus(userId, paid);
    }

    private static List<Cart__c> getCartUsingStatus(String userId, String status) {
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
    public static Integer getCartItemsCount(String userId) {
        return [
            SELECT COUNT()
            FROM Cart__c
            WHERE UserId__c = :userId
                  AND Status__c = :added
        ];
    }

    @AuraEnabled
    public static Boolean payForOrder(String userId) {
        List<Cart__c> cart = getCart(userId);

        Double bill = 0;
        for (Cart__c item: cart) {
            bill += item.Quantity__c * item.ProductId__r.Price__c;
        }

        if (!OnlineStoreBankingController.widthdrawFromCard(userId, bill)) return false;

        List<Product__c> products = new List<Product__c>();
        for (Cart__c item : cart) {
            if (item.Quantity__c < item.ProductId__r.InStock__c) throw new InvalidInputException(noSuchQuantity);
            item.Status__c = paid;
            products.add(item.ProductId__r);
        }
        update cart;
        update products;
        return true;
    }
}
