public with sharing class OnlineStoreProductsController {
    public inherited sharing class ProductWrapper {
        public List<Product__c> products;
        public Integer totalPages;
    
        public ProductWrapper(List<Product__c> pl, Integer t) {
            products = pl;
            totalPages = t;
        }
    }

    public inherited sharing class FiltersWrapper {
        public Integer minPrice { get; set; }
        public Integer maxPrice { get; set; }
        public List<String> chosenCategories { get; set; }
    }

    @AuraEnabled
    public static String getProducts(Integer page, Integer productsOnPage) {
        Integer offset = (page - 1) * productsOnPage;

        Integer totalProducts = [SELECT COUNT() FROM Product__c WHERE InStock__c > 0];
        List<Product__c> products = [
            SELECT 
                Id, Name, Description__c, Image__c, InStock__c, Price__c, (
                    SELECT CategoryId__r.Name, CategoryId__r.ParentId__r.Name 
                    FROM ProductCategories__r
                    ORDER BY CategoryId__r.ParentId__r.Name
                )
            FROM Product__c
            WHERE InStock__c > 0
            LIMIT :productsOnPage
            OFFSET :offset
        ];

        Integer totalPages = (Integer)Math.ceil((Double)totalProducts / (Double)productsOnPage);        
        return JSON.serialize(new ProductWrapper(products, totalPages));
    }

    @AuraEnabled
    public static String getProductsUsingFilters(Integer page, Integer productsOnPage, string filters) {
        FiltersWrapper fs = (FiltersWrapper)JSON.deserialize(filters, FiltersWrapper.class);
        
        Integer offset = (page - 1) * productsOnPage;

        Integer totalChosen = fs.chosenCategories.size();

        Map<String,Integer> counterMap = new Map<String,Integer>();
        List<Product__c> possibleProducts = [SELECT Id FROM Product__c];
        for (Product__c product : possibleProducts) {
            counterMap.put(product.Id, 0);
        }

        List<Category__c> categories = [
            SELECT Name, (
                SELECT ProductId__c FROM ProductCategories__r
            )
            FROM Category__c
            WHERE Id IN :fs.chosenCategories
        ];

        for (Category__c category : categories) {
            for (ProductCategories__c prodCat : category.ProductCategories__r) {
                String productId = prodCat.ProductId__c;
                counterMap.put(productId, counterMap.get(productId) + 1);
            }
        }

        List<String> productIds = new List<String>();
        for (String id : counterMap.keySet()) {
            Integer matchingCount = counterMap.get(id);
            if (totalChosen == matchingCount) productIds.add(id);
        }

        Integer totalProducts = [
            SELECT COUNT() 
            FROM Product__c 
            WHERE 
                InStock__c > 0 AND 
                Price__c > :fs.minPrice AND 
                Price__c < :fs.maxPrice AND 
                Id IN :productIds
        ];

        List<Product__c> products = [
            SELECT 
                Id, Name, Description__c, Image__c, InStock__c, Price__c, (
                    SELECT CategoryId__r.Name, CategoryId__r.ParentId__r.Name 
                    FROM ProductCategories__r
                    ORDER BY CategoryId__r.ParentId__r.Name
                )
            FROM Product__c
            WHERE 
                InStock__c > 0 AND 
                Price__c > :fs.minPrice AND 
                Price__c < :fs.maxPrice AND 
                Id IN :productIds
            LIMIT :productsOnPage
            OFFSET :offset
        ];

        Integer totalPages = (Integer)Math.ceil((Double)totalProducts / (Double)productsOnPage);        
        return JSON.serialize(new ProductWrapper(products, totalPages));
    }
    
    @AuraEnabled
    public static List<Category__c> getCategories() {
        return [
            SELECT Name, (
                SELECT Id, Name FROM Subcategories__r WHERE Id IN (
                    SELECT CategoryId__c 
                    FROM ProductCategories__c 
                    WHERE ProductId__c <> NULL
            	)
            )
            FROM Category__c WHERE ParentId__c = NULL 
        ];
    }

    @AuraEnabled
    public static Integer addToCart(String userId, String productId, Integer quantity) {
        return OnlineStoreCartController.addToCart(userId, productId, quantity);
    }
}