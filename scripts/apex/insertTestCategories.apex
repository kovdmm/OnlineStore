// CATEGORIES
List<Category__c> categories = new List<Category__c>();

categories.add(new Category__c(Name = 'Vendor'));
categories.add(new Category__c(Name = 'Color'));
categories.add(new Category__c(Name = 'Memory'));
categories.add(new Category__c(Name = 'RAM'));
categories.add(new Category__c(Name = 'Screen'));

insert categories;

// SUBCATEGORIES
List<Category__c> subcategories = new List<Category__c>();

// Vendor
subcategories.add(new Category__c(Name = 'Apple', ParentId__c = categories[0].Id));
subcategories.add(new Category__c(Name = 'Huawei', ParentId__c = categories[0].Id));
subcategories.add(new Category__c(Name = 'Samsung', ParentId__c = categories[0].Id));
subcategories.add(new Category__c(Name = 'Xiaomi', ParentId__c = categories[0].Id));

// Color
subcategories.add(new Category__c(Name = 'White', ParentId__c = categories[1].Id));
subcategories.add(new Category__c(Name = 'Black', ParentId__c = categories[1].Id));
subcategories.add(new Category__c(Name = 'Gold', ParentId__c = categories[1].Id));
subcategories.add(new Category__c(Name = 'Grey', ParentId__c = categories[1].Id));
subcategories.add(new Category__c(Name = 'Red', ParentId__c = categories[1].Id));

// Memory
subcategories.add(new Category__c(Name = '16GB', ParentId__c = categories[2].Id));
subcategories.add(new Category__c(Name = '32GB', ParentId__c = categories[2].Id));
subcategories.add(new Category__c(Name = '64GB', ParentId__c = categories[2].Id));
subcategories.add(new Category__c(Name = '128GB', ParentId__c = categories[2].Id));
subcategories.add(new Category__c(Name = '256GB', ParentId__c = categories[2].Id));

// RAM
subcategories.add(new Category__c(Name = '2GB', ParentId__c = categories[3].Id));
subcategories.add(new Category__c(Name = '4GB', ParentId__c = categories[3].Id));
subcategories.add(new Category__c(Name = '6GB', ParentId__c = categories[3].Id));

// Screen
subcategories.add(new Category__c(Name = '5"', ParentId__c = categories[4].Id));
subcategories.add(new Category__c(Name = '5.5"', ParentId__c = categories[4].Id));
subcategories.add(new Category__c(Name = '6.2"', ParentId__c = categories[4].Id));

insert subcategories;

System.debug('Categories successfully added!');
System.debug('List<Category__c>:' + [SELECT Name FROM Category__c]);