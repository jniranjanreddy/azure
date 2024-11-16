```
// https://learn.microsoft.com/en-us/kusto/query/count-aggregation-function
// We can use the count aggregation function
SecurityEvent
| where EventID in (4674,4672,4624)
| count
 
// We can also do a count per summarization group
SecurityEvent
| where EventID in (4625,4776)
| summarize Count=count() by EventID
 
// We can group by multiple columns
SecurityEvent
| summarize Count=count() by EventID,SubjectUserName
 
// If we want to sort the events based on the time generated
// https://learn.microsoft.com/en-us/kusto/query/bin-function
SecurityEvent
| where EventID in (4625,4776)
| summarize Count=count() by bin(TimeGenerated,10m)
```
```
// We only want to project certain columns in the result set
SecurityEvent
| where EventID in (4674,4672,4624)
| project Account,AccountType,EventID,TargetAccount
 
// Getting embedded objects in data
// We want to try to project the resource under Properties
// We will go step by step
// We need to ensure that the type of column is dynamic in nature
 
AzureActivity
| project ResourceGroup,Caller,Resource=Properties_d["resource"]
 
// If we look at the HTTPRequest, we get a list of JSON based objects, this is of the type string
AzureActivity
| project HTTPRequest
 
// If we want to extract the individual values, we can first convert it to a dynamic object and then extract the contents
// extend - https://learn.microsoft.com/en-us/kusto/query/extend-operator
 
AzureActivity
| extend request=todynamic(HTTPRequest)
| project request["clientIpAddress"]
```
