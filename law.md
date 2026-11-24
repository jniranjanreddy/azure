## This Page us for only LAW.

## Azure Gateway for Containers Logs..
```
There are three kinds of user query statements:

A tabular expression statement
A let statement
A set statement

```

```

Below is a comprehensive KQL operator reference with simple examples.
1. Filtering and searching operators
Assume we have a table named AppLogs.
Operator	Purpose	Example
where	Filter rows	AppLogs \| where Level == "Error"
search	Search across tables	search "timeout"
find	Find matching values across tables	find "timeout"
take	Return first N rows	AppLogs \| take 10
limit	Limit output rows	AppLogs \| limit 5
top	Return top rows by column	AppLogs \| top 5 by TimeGenerated desc
sample	Random sample	AppLogs \| sample 10
distinct	Unique values	AppLogs \| distinct Level
getschema	Display table schema	AppLogs \| getschema
count	Count rows	AppLogs \| count

2. Comparison operators
Operator	Meaning	Example
==	Equal	\| where Level == "Error"
!=	Not equal	\| where Level != "Info"
>	Greater than	\| where Duration > 500
<	Less than	\| where Duration < 100
>=	Greater than or equal	\| where Duration >= 500
<=	Less than or equal	\| where Duration <= 100
between	Within a range	\| where Duration between (100 .. 500)
in	Matches any listed value	\| where Level in ("Error", "Warning")
!in	Does not match listed values	\| where Level !in ("Info", "Debug")
has	Contains a term	\| where Message has "timeout"
!has	Does not contain a term	\| where Message !has "timeout"
contains	Contains substring	\| where Message contains "time"
!contains	Does not contain substring	\| where Message !contains "time"
startswith	Starts with text	\| where Message startswith "Connection"
endswith	Ends with text	\| where Message endswith "failed"
matches regex	Regular expression match	\| where Message matches regex @"error\|fail"
hasprefix	Term starts with text	\| where Message hasprefix "conn"
hassuffix	Term ends with text	\| where Message hassuffix "failed"

Important distinction:
- has searches for complete terms.
- contains searches for substrings.
- == performs exact equality.
- in checks against multiple exact values.
3. Logical operators
Operator	Meaning	Example
and	Both conditions true	\| where Level == "Error" and Duration > 500
or	Either condition true	\| where Level == "Error" or Level == "Warning"
not	Negates condition	\| where not(Level == "Info")
!	Logical NOT	\| where !(Duration > 500)

4. Projection and column operators
Operator	Purpose	Example
project	Select columns	\| project TimeGenerated, Level
project-away	Remove columns	\| project-away Message
project-keep	Keep specified columns	\| project-keep Level, Message
project-rename	Rename columns	\| project-rename Severity = Level
project-reorder	Change column order	\| project-reorder Level, TimeGenerated
extend	Create calculated column	\| extend DurationSec = Duration / 1000.0
serialize	Mark row order as serialized	\| serialize
invoke	Invoke a tabular function	\| invoke MyFunction()

5. Aggregation operators
Operator	Purpose	Example
summarize	Aggregate data	\| summarize count()
count	Count records	\| summarize count()
sum()	Calculate total	\| summarize sum(Duration)
avg()	Calculate average	\| summarize avg(Duration)
min()	Minimum value	\| summarize min(Duration)
max()	Maximum value	\| summarize max(Duration)
dcount()	Approximate distinct count	\| summarize dcount(UserId)
countif()	Count matching rows	\| summarize countif(Level == "Error")
sumif()	Sum matching rows	\| summarize sumif(Duration, Level == "Error")
avgif()	Average matching rows	\| summarize avgif(Duration, Level == "Error")
percentile()	Calculate percentile	\| summarize percentile(Duration, 95)
percentiles()	Multiple percentiles	\| summarize percentiles(Duration, 50, 95, 99)
make_set()	Create unique-value array	\| summarize make_set(Level)
make_list()	Create value array	\| summarize make_list(Level)
arg_max()	Return row with maximum value	\| summarize arg_max(TimeGenerated, *)
arg_min()	Return row with minimum value	\| summarize arg_min(TimeGenerated, *)
any()	Return an arbitrary value	\| summarize any(Message)
take_any()	Return arbitrary row/value	\| summarize take_any(Message)
variance()	Calculate variance	\| summarize variance(Duration)
stdev()	Calculate standard deviation	\| summarize stdev(Duration)

6. Sorting and ordering operators
Operator	Purpose	Example
sort	Sort rows	\| sort by TimeGenerated desc
order	Alias for sort	\| order by Duration asc
top	Get top N records	\| top 10 by Duration desc
top-hitters	Find most frequent values	\| top-hitters 5 of PodName
sample-distinct	Sample distinct values	\| sample-distinct 5 of PodName

- asc = ascending order.
- desc = descending order.
7. Join and combining operators
These are particularly important when correlating Kubernetes, application, and infrastructure logs.
Operator	Purpose	Example
join	Combine two tables	Pods \| join kind=inner (Events) on PodName
lookup	Join with a smaller lookup table	Pods \| lookup kind=leftouter (NodeInfo) on NodeName
union	Combine rows from multiple tables	union AppLogs, AuditLogs
materialize()	Cache a tabular expression	let T = materialize(AppLogs); T \| count
as	Give a name to a tabular expression	AppLogs \| as Logs \| where Level == "Error"

Join types
Join type	Meaning
inner	Matching rows from both tables
leftouter	All left rows and matching right rows
rightouter	All right rows and matching left rows
fullouter	All rows from both tables
leftanti	Rows from left without a match on right
rightanti	Rows from right without a match on left
leftsemi	Matching rows from left only
rightsemi	Matching rows from right only
innerunique	Inner join with unique left-side keys

Example:
Pods
| join kind=leftouter (
    Nodes
) on NodeName
| project PodName, NodeName, NodeStatus


8. String manipulation operators and functions
Operator / Function	Purpose	Example
strcat()	Combine strings	print strcat("AKS", "-Cluster")
strlen()	String length	print strlen("Kubernetes")
substring()	Extract substring	print substring("Kubernetes", 0, 4)
toupper()	Convert to uppercase	print toupper("aks")
tolower()	Convert to lowercase	print tolower("AKS")
trim()	Remove surrounding characters	print trim(" ", " AKS ")
replace_string()	Replace text	print replace_string("pod-failed", "failed", "running")
split()	Split string into array	print split("aks,pod,node", ",")
strcat_array()	Join array elements	print strcat_array(dynamic(["aks","pod"]), "-")
extract()	Extract using regex	print extract(@"pod-(\d+)", 1, "pod-123")
extract_all()	Extract all regex matches	print extract_all(@"[0-9]+", "pod-12-node-34")
parse_url()	Parse URL components	print parse_url("https://example.com/api")
parse_ipv4()	Convert IPv4 to numeric value	print parse_ipv4("192.168.1.1")
indexof()	Find substring position	print indexof("kubernetes", "netes")
reverse()	Reverse string	print reverse("AKS")
translate()	Replace individual characters	print translate("abc", "abc", "123")
has_any	Match any term in a list	AppLogs \| where Message has_any ("timeout", "failure")
contains_cs	Case-sensitive substring search	AppLogs \| where Message contains_cs "ERROR"
has_cs	Case-sensitive term search	AppLogs \| where Message has_cs "ERROR"

9. Time and datetime operators/functions
Very useful for troubleshooting production incidents.
Function / Operator	Purpose	Example
now()	Current UTC time	print now()
ago()	Time in the past	AppLogs \| where TimeGenerated > ago(1h)
datetime()	Define datetime	print datetime(2026-11-24)
timespan()	Define duration	print timespan(01:00:00)
bin()	Group into time intervals	AppLogs \| summarize count() by bin(TimeGenerated, 5m)
bin_at()	Group relative to a fixed point	AppLogs \| summarize count() by bin_at(TimeGenerated, 1h, datetime(2026-11-24))
startofday()	Start of day	print startofday(now())
endofday()	End of day	print endofday(now())
startofweek()	Start of week	print startofweek(now())
endofweek()	End of week	print endofweek(now())
startofmonth()	Start of month	print startofmonth(now())
endofmonth()	End of month	print endofmonth(now())
startofyear()	Start of year	print startofyear(now())
endofyear()	End of year	print endofyear(now())
datetime_diff()	Difference between datetimes	print datetime_diff("minute", now(), ago(1h))
format_datetime()	Format datetime	print format_datetime(now(), "yyyy-MM-dd")
dayofweek()	Get day of week	print dayofweek(now())
dayofmonth()	Get day of month	print dayofmonth(now())
getmonth()	Get month number	print getmonth(now())
getyear()	Get year	print getyear(now())
hourofday()	Get hour	print hourofday(now())
unixtime_seconds_todatetime()	Convert Unix seconds	print unixtime_seconds_todatetime(1700000000)
datetime_utc_to_local()	Convert UTC to local time	print datetime_utc_to_local(now(), "US/Eastern")

10. Dynamic JSON operators and functions
Important when working with Kubernetes JSON logs, API responses, and Azure resource data.
Operator / Function	Purpose	Example
dynamic	Create dynamic object	print d = dynamic({"pod":"api","status":500})
parse_json()	Parse JSON string	print parse_json('{"pod":"api"}')
todynamic()	Convert to dynamic	print todynamic('{"pod":"api"}')
tostring()	Convert to string	print tostring(123)
toint()	Convert to integer	print toint("100")
tolong()	Convert to long	print tolong("1000")
todouble()	Convert to double	print todouble("12.5")
tobool()	Convert to boolean	print tobool("true")
gettype()	Get data type	print gettype(dynamic({"pod":"api"}))
bag_keys()	Get JSON property names	print bag_keys(dynamic({"pod":"api","status":500}))
bag_pack()	Create property bag	print bag_pack("pod","api","status",500)
bag_unpack	Expand JSON properties into columns	datatable(d:dynamic)[dynamic({"pod":"api"})] \| evaluate bag_unpack(d)
mv-expand	Expand array into rows	print d=dynamic(["api","worker"]) \| mv-expand d
mv-apply	Apply operations to array elements	print d=dynamic([1,2,3]) \| mv-apply x=d on (summarize total=sum(toint(x)))
array_length()	Get array size	print array_length(dynamic([1,2,3]))
array_concat()	Combine arrays	print array_concat(dynamic([1]), dynamic([2]))
set_union()	Union array values	print set_union(dynamic([1,2]), dynamic([2,3]))
pack_array()	Create array	print pack_array("api","worker")
array_sort_asc()	Sort array ascending	print array_sort_asc(dynamic([3,1,2]))
array_sort_desc()	Sort array descending	print array_sort_desc(dynamic([3,1,2]))
array_index_of()	Find array element	print array_index_of(dynamic(["api","worker"]), "api")

11. Parsing operators
Operator	Purpose	Example
parse	Extract structured fields	AppLogs \| parse Message with "Pod:" PodName " Status:" Status
parse-where	Parse and retain matching rows	AppLogs \| parse-where Message with "Pod:" PodName
parse-kv	Parse key-value text	AppLogs \| extend d=parse_kv(Message)
extract	Extract regex value	AppLogs \| extend PodId=extract(@"pod-(\d+)", 1, Message)
parse_json	Parse JSON data	AppLogs \| extend Data=parse_json(Message)
evaluate bag_unpack	Expand dynamic properties	AppLogs \| evaluate bag_unpack(Properties)

12. Statistical and mathematical functions
Function	Purpose	Example
abs()	Absolute value	print abs(-10)
round()	Round number	print round(12.567, 2)
floor()	Round down	print floor(12.9)
ceiling()	Round up	print ceiling(12.1)
sqrt()	Square root	print sqrt(25)
pow()	Power	print pow(2, 3)
log()	Natural logarithm	print log(10)
log10()	Base-10 logarithm	print log10(100)
exp()	Exponential	print exp(1)
rand()	Random number	print rand()
sign()	Sign of number	print sign(-10)
round()	Round to precision	print round(15.678, 1)
percentile()	Calculate percentile	AppLogs \| summarize percentile(Duration, 99)

13. Series and time-series operators
Useful for CPU, memory, latency, request rate, and anomaly detection.
Operator / Function	Purpose	Example
make-series	Build time-series data	AppLogs \| make-series Errors=count() default=0 on TimeGenerated from ago(1h) to now() step 5m
series_decompose()	Decompose time series	print s=dynamic([1,2,3,4,5]) \| extend d=series_decompose(s)
series_outliers()	Detect outliers	print s=dynamic([1,2,3,100,2]) \| extend o=series_outliers(s)
series_fit_line()	Fit linear trend	print s=dynamic([1,2,3,4,5]) \| extend f=series_fit_line(s)
series_stats()	Calculate series statistics	print s=dynamic([1,2,3,4]) \| extend stats=series_stats(s)
series_fill_linear()	Fill missing values	print s=dynamic([1,real(null),3]) \| extend f=series_fill_linear(s)
series_fill_forward()	Fill using previous values	print s=dynamic([1,real(null),3]) \| extend f=series_fill_forward(s)

14. Additional tabular operators
These are useful when building advanced queries and troubleshooting large datasets.
Operator	Purpose	Example
filter	Filter records; synonym for where	AppLogs \| filter Level == "Error"
range	Generate a sequence	range Number from 1 to 10 step 1
print	Print calculated values	print Environment = "QA"
datatable	Create an inline table	datatable(Name:string, Age:int)[ "John", 30 ]
let	Define reusable variables	let Env = "QA"; AppLogs \| where Environment == Env
fork	Run multiple query branches	AppLogs \| fork (where Level == "Error") (where Level == "Warning")
facet	Explore values across columns	AppLogs \| facet by Level
partition	Execute subqueries for partitions	AppLogs \| partition by PodName (top 5 by TimeGenerated)
scan	Perform stateful row processing	AppLogs \| sort by TimeGenerated asc \| scan declare (n:long=0) with (step s: true => n = s.n + 1)
reduce	Group similar strings into patterns	AppLogs \| reduce by Message with threshold=0.1
evaluate	Run a query plugin	AppLogs \| evaluate bag_unpack(Properties)
render	Visualize query results	AppLogs \| summarize count() by Level \| render piechart
mv-apply	Apply a subquery to expanded arrays	AppLogs \| mv-apply x=Tags on (where x == "critical")
top-nested	Get hierarchical top values	AppLogs \| top-nested 3 of Level by count(), top-nested 2 of PodName by count()
consume	Consume query output without returning it	AppLogs \| consume

15. Null and empty-value functions
Function	Purpose	Example
isnull()	Check null	AppLogs \| where isnull(Message)
isnotnull()	Check not null	AppLogs \| where isnotnull(Message)
isempty()	Check empty string	AppLogs \| where isempty(Message)
isnotempty()	Check non-empty string	AppLogs \| where isnotempty(Message)
isnan()	Check NaN	AppLogs \| where isnan(Duration)
coalesce()	Return first non-null value	AppLogs \| extend Result=coalesce(Message, "Unknown")
iff()	Conditional expression	AppLogs \| extend Status=iff(Duration > 500, "Slow", "Normal")
case()	Multiple conditional branches	AppLogs \| extend Status=case(Duration > 1000, "Critical", Duration > 500, "Slow", "Normal")
iif()	Conditional expression	AppLogs \| extend Result=iif(Duration > 500, "Slow", "Fast")

16. Arithmetic and scalar operators
Operator	Purpose	Example
+	Addition	print 10 + 5
-	Subtraction	print 10 - 5
*	Multiplication	print 10 * 5
/	Division	print 10 / 5
%	Modulus	print 10 % 3
==	Equality	print 10 == 10
!=	Inequality	print 10 != 5
>	Greater than	print 10 > 5
<	Less than	print 5 < 10
>=	Greater than or equal	print 10 >= 10
<=	Less than or equal	print 5 <= 10
and	Logical AND	print 10 > 5 and 5 > 2
or	Logical OR	print 10 > 5 or 5 < 2
!	Logical NOT	print !false

17. Query statements and configuration
These aren't ordinary pipeline operators, but they're important KQL language constructs.
Statement	Purpose	Example
let	Define variables	let threshold = 500; print threshold
set	Set query options	set query_take_max_records = 100; AppLogs
declare query_parameters	Declare parameters	declare query_parameters (env:string); AppLogs \| where Environment == env


18. Practical KQL examples for Azure and Kubernetes
Here are some queries worth learning and practicing.

Example 1: Find all application errors
AppLogs
| where Level == "Error"
| project TimeGenerated, PodName, Message
| sort by TimeGenerated desc


Example 2: Find errors in the last 24 hours
AppLogs
| where TimeGenerated > ago(24h)
| where Level == "Error"
| count


Example 3: Find the top 10 pods generating errors
AppLogs
| where Level == "Error"
| summarize ErrorCount = count() by PodName
| top 10 by ErrorCount desc


Example 4: Find slow API requests
AppLogs
| where Duration > 1000
| project TimeGenerated, APIName, Duration
| order by Duration desc


Example 5: Calculate error percentage
AppLogs
| summarize
    TotalRequests = count(),
    FailedRequests = countif(Level == "Error")
| extend ErrorPercentage =
    round(100.0 * FailedRequests / TotalRequests, 2)


Example 6: Group errors every five minutes
AppLogs
| where Level == "Error"
| summarize ErrorCount = count()
    by bin(TimeGenerated, 5m)
| render timechart


Example 7: Find unique Kubernetes pods
AppLogs
| distinct PodName


Example 8: Find pods with multiple errors
AppLogs
| where Level == "Error"
| summarize ErrorCount = count() by PodName
| where ErrorCount > 10
| sort by ErrorCount desc


Example 9: Extract HTTP status codes from JSON
AppLogs
| extend Data = parse_json(Message)
| extend StatusCode = toint(Data.statusCode)
| where StatusCode >= 500
| project TimeGenerated, PodName, StatusCode


Example 10: Find the 95th percentile API response time
AppLogs
| summarize P95 = percentile(Duration, 95)
    by APIName
| sort by P95 desc



19. Which operators should you master first?
For DevOps, Azure infrastructure, and observability, I recommend this learning order:
KQL learning roadmap
01
Fundamentals

where, project, take, count, distinct, sort, top


02
Filtering

has, contains, in, between, matches regex, and, or


03
Aggregation

summarize, countif, avg, sum, dcount, percentile


04
Time analysis

ago, now, bin, datetime_diff, make-series


05
Data transformation

extend, parse, parse_json, mv-expand, bag_unpack


06
Correlation

join, lookup, union, let, materialize


07
Advanced analytics

render, series_outliers, scan, partition, evaluate



Important: KQL has a distinction between tabular operators (such as where, join, summarize) and scalar or aggregation functions (such as tolower(), avg(), and countif()). I've included both because you'll use them together. Some operators and plugins have different availability across Azure Data Explorer, Log Analytics, and Microsoft Sentinel.
20. Official Microsoft references
- KQL Quick Reference
- KQL Query Operators
- Learn Common KQL Operators
- KQL Aggregation Functions
- KQL Query Best Practices
My recommendation: practice these against your actual AKS and Application Insights logs. You will learn KQL much faster by answering real troubleshooting questions than by memorizing operators.
```

