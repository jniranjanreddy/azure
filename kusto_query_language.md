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
