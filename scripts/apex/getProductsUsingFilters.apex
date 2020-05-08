// input data
List<String> chosenCategories = new List<String>();
chosenCategories.add('a025I000001LrTmQAK');
chosenCategories.add('a025I000001LrTxQAK');
chosenCategories.add('a025I000001LwHyQAK');

// METHOD STARTS HERE
Integer totalChosen = chosenCategories.size();

Map<String,Integer> counterMap = new Map<String,Integer>();
List<Product__c> possibleProducts = [SELECT Id FROM Product__c];
for (Product__c product : possibleProducts) {
    counterMap.put(product.Id, 0);
}

// Запрос продуктов у каждой выбранной категории
List<Category__c> categories = [
    SELECT Name, (
        SELECT ProductId__c FROM ProductCategories__r
    )
    FROM Category__c
    WHERE Id IN :chosenCategories
];

// Пересчёт попаданий в категории
for (Category__c category : categories) {
    for (ProductCategories__c prodCat : category.ProductCategories__r) {
        String productId = prodCat.ProductId__c;
        counterMap.put(productId, counterMap.get(productId) + 1);
    }
}

System.debug(counterMap);

// Формирование списка продуктов с id, которые попали во все категории
List<String> productIds = new List<String>();
for (String id : counterMap.keySet()) {
    Integer matchingCount = counterMap.get(id);
    if (totalChosen == matchingCount) productIds.add(id);
}

// Получение всех необходимых полей продуктов
List<Product__c> products = [
	SELECT 
		Id, Name, Description__c, Image__c, InStock__c, Price__c, (
			SELECT CategoryId__r.Name, CategoryId__r.ParentId__r.Name 
			FROM ProductCategories__r
		)
	FROM Product__c
	WHERE 
		InStock__c > 0 AND
		Id IN :productIds
];


// Количество продуктов, попавших во все категории
System.debug(products.size());
