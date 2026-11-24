# Azure Kusto Query Language (KQL) Operators Cheat Sheet

A practical reference for Azure Data Explorer, Azure Monitor Logs, Log
Analytics, Application Insights, and Microsoft Sentinel.

> **Note:** KQL availability can vary by service. Some items below are
> tabular operators, while others are scalar, aggregation, or series
> functions. The examples use illustrative tables and column names;
> replace them with your workspace's actual schema.

## Table of contents

1.  [Basic query structure](#1-basic-query-structure)
2.  [Filtering and searching](#2-filtering-and-searching)
3.  [Comparison operators](#3-comparison-operators)
4.  [Logical operators](#4-logical-operators)
5.  [Projection and column shaping](#5-projection-and-column-shaping)
6.  [Sorting, limiting, and sampling](#6-sorting-limiting-and-sampling)
7.  [Aggregation](#7-aggregation)
8.  [Joining and combining tables](#8-joining-and-combining-tables)
9.  [String functions and operators](#9-string-functions-and-operators)
10. [Datetime and timespan
    functions](#10-datetime-and-timespan-functions)
11. [Dynamic data and JSON](#11-dynamic-data-and-json)
12. [Parsing](#12-parsing)
13. [Null, empty, and conditional
    functions](#13-null-empty-and-conditional-functions)
14. [Math and conversion functions](#14-math-and-conversion-functions)
15. [Arrays and multi-value data](#15-arrays-and-multi-value-data)
16. [Time-series analysis](#16-time-series-analysis)
17. [Other useful tabular operators](#17-other-useful-tabular-operators)
18. [Query statements](#18-query-statements)
19. [DevOps and AKS troubleshooting
    examples](#19-devops-and-aks-troubleshooting-examples)
20. [Recommended learning order](#20-recommended-learning-order)

------------------------------------------------------------------------

## 1. Basic query structure

KQL queries commonly use the pipe (`|`) to pass the result of one
operator to the next.

``` kusto
AppLogs
| where Level == "Error"
| project TimeGenerated, PodName, Message
| sort by TimeGenerated desc
| take 20
```

  -----------------------------------------------------------------------------------------------
  Keyword                 Purpose                 Example
  ----------------------- ----------------------- -----------------------------------------------
  `print`                 Produce a row of        `print Environment = "QA"`
                          calculated values       

  `let`                   Define a reusable       `let threshold = 500; print threshold`
                          variable or expression  

  `datatable`             Create an inline table  `datatable(Name:string, Age:int) ["Sam", 30]`

  `range`                 Generate a sequence     `range Number from 1 to 5 step 1`
  -----------------------------------------------------------------------------------------------

## 2. Filtering and searching

Assume a table named `AppLogs`.

  -------------------------------------------------------------------------------------------------------------
  Operator                Purpose                 Example
  ----------------------- ----------------------- -------------------------------------------------------------
  `where`                 Keep rows matching a    `AppLogs \| where Level == "Error"`
                          condition               

  `filter`                Alias for `where`       `AppLogs \| filter Level == "Error"`

  `search`                Search across tables or `search "timeout"`
                          columns                 

  `find`                  Search values across    `find "timeout"`
                          tables                  

  `has`                   Match a complete term   `AppLogs \| where Message has "timeout"`

  `!has`                  Exclude a complete term `AppLogs \| where Message !has "timeout"`

  `contains`              Match a substring       `AppLogs \| where Message contains "time"`

  `!contains`             Exclude a substring     `AppLogs \| where Message !contains "time"`

  `has_cs`                Case-sensitive term     `AppLogs \| where Message has_cs "ERROR"`
                          match                   

  `contains_cs`           Case-sensitive          `AppLogs \| where Message contains_cs "ERROR"`
                          substring match         

  `startswith`            Match beginning of      `AppLogs \| where Message startswith "Connection"`
                          string                  

  `endswith`              Match end of string     `AppLogs \| where Message endswith "failed"`

  `hasprefix`             Match a term prefix     `AppLogs \| where Message hasprefix "time"`

  `hassuffix`             Match a term suffix     `AppLogs \| where Message hassuffix "out"`

  `matches regex`         Match a regular         `AppLogs \| where Message matches regex @"error\|fail"`
                          expression              

  `has_any`               Match any term in a     `AppLogs \| where Message has_any ("timeout", "failure")`
                          list                    

  `has_all`               Match all terms in a    `AppLogs \| where Message has_all ("connection", "failed")`
                          list                    
  -------------------------------------------------------------------------------------------------------------

**Important:** `has` uses term matching, while `contains` uses substring
matching. For example, `has "cat"` matches the term `cat`;
`contains "cat"` can also match `concatenate`.

## 3. Comparison operators

  ----------------------------------------------------------------------------------------------------
  Operator                Meaning                 Example
  ----------------------- ----------------------- ----------------------------------------------------
  `==`                    Equal                   `AppLogs \| where Level == "Error"`

  `!=`                    Not equal               `AppLogs \| where Level != "Info"`

  `>`                     Greater than            `AppLogs \| where DurationMs > 500`

  `<`                     Less than               `AppLogs \| where DurationMs < 100`

  `>=`                    Greater than or equal   `AppLogs \| where DurationMs >= 500`

  `<=`                    Less than or equal      `AppLogs \| where DurationMs <= 100`

  `between`               Inclusive range         `AppLogs \| where DurationMs between (100 .. 500)`

  `in`                    Match any listed value  `AppLogs \| where Level in ("Error", "Warning")`

  `!in`                   Match none of the       `AppLogs \| where Level !in ("Info", "Debug")`
                          listed values           

  `in~`                   Case-insensitive        `AppLogs \| where Level in~ ("error", "warning")`
                          membership              

  `!in~`                  Case-insensitive        `AppLogs \| where Level !in~ ("info", "debug")`
                          exclusion               
  ----------------------------------------------------------------------------------------------------

## 4. Logical operators

  -----------------------------------------------------------------------------------------------------------
  Operator                Meaning                 Example
  ----------------------- ----------------------- -----------------------------------------------------------
  `and`                   Both conditions must be `AppLogs \| where Level == "Error" and DurationMs > 500`
                          true                    

  `or`                    At least one condition  `AppLogs \| where Level == "Error" or Level == "Warning"`
                          must be true            

  `not`                   Negate a condition      `AppLogs \| where not(Level == "Info")`

  `!`                     Logical NOT             `AppLogs \| where !(DurationMs > 500)`
  -----------------------------------------------------------------------------------------------------------

Use parentheses when combining several `and` and `or` conditions to make
the intended logic clear.

## 5. Projection and column shaping

  -------------------------------------------------------------------------------------------------------
  Operator                Purpose                 Example
  ----------------------- ----------------------- -------------------------------------------------------
  `project`               Select or calculate     `AppLogs \| project TimeGenerated, Level`
                          output columns          

  `project-away`          Remove columns          `AppLogs \| project-away RawPayload`

  `project-keep`          Keep specified columns  `AppLogs \| project-keep Level, Message`

  `project-rename`        Rename columns          `AppLogs \| project-rename Severity = Level`

  `project-reorder`       Change column order     `AppLogs \| project-reorder Level, TimeGenerated`

  `extend`                Add or calculate        `AppLogs \| extend DurationSec = DurationMs / 1000.0`
                          columns                 

  `serialize`             Mark row set as         `AppLogs \| sort by TimeGenerated asc \| serialize`
                          serialized              
  -------------------------------------------------------------------------------------------------------

## 6. Sorting, limiting, and sampling

  -------------------------------------------------------------------------------------------
  Operator                Purpose                 Example
  ----------------------- ----------------------- -------------------------------------------
  `sort` / `order`        Sort rows               `AppLogs \| sort by TimeGenerated desc`

  `top`                   Return highest or       `AppLogs \| top 10 by DurationMs desc`
                          lowest N rows           

  `take`                  Return up to N rows     `AppLogs \| take 10`

  `limit`                 Alias for `take`        `AppLogs \| limit 10`

  `sample`                Return a random sample  `AppLogs \| sample 10`

  `sample-distinct`       Sample distinct values  `AppLogs \| sample-distinct 5 of PodName`

  `top-hitters`           Find frequent values    `AppLogs \| top-hitters 5 of PodName`
                          using approximate       
                          counting                

  `distinct`              Return unique           `AppLogs \| distinct PodName, Namespace`
                          combinations            
  -------------------------------------------------------------------------------------------

`take` does not guarantee a particular order. Use `sort` before `take`
when order matters.

## 7. Aggregation

Aggregations are commonly used with `summarize`.

  -------------------------------------------------------------------------------------------------------------
  Function / operator     Purpose                 Example
  ----------------------- ----------------------- -------------------------------------------------------------
  `summarize`             Aggregate rows          `AppLogs \| summarize count()`

  `count()`               Count rows              `AppLogs \| summarize count()`

  `sum()`                 Sum values              `AppLogs \| summarize sum(DurationMs)`

  `avg()`                 Average                 `AppLogs \| summarize avg(DurationMs)`

  `min()`                 Minimum                 `AppLogs \| summarize min(DurationMs)`

  `max()`                 Maximum                 `AppLogs \| summarize max(DurationMs)`

  `dcount()`              Approximate distinct    `AppLogs \| summarize dcount(UserId)`
                          count                   

  `countif()`             Count rows matching a   `AppLogs \| summarize countif(Level == "Error")`
                          condition               

  `sumif()`               Sum values matching a   `AppLogs \| summarize sumif(DurationMs, Level == "Error")`
                          condition               

  `avgif()`               Average values matching `AppLogs \| summarize avgif(DurationMs, Level == "Error")`
                          a condition             

  `percentile()`          Calculate one           `AppLogs \| summarize percentile(DurationMs, 95)`
                          percentile              

  `percentiles()`         Calculate multiple      `AppLogs \| summarize percentiles(DurationMs, 50, 95, 99)`
                          percentiles             

  `make_set()`            Make an array of        `AppLogs \| summarize make_set(PodName)`
                          distinct values         

  `make_list()`           Make an array of values `AppLogs \| summarize make_list(Level)`

  `arg_max()`             Return row with maximum `AppLogs \| summarize arg_max(TimeGenerated, *) by PodName`
                          value                   

  `arg_min()`             Return row with minimum `AppLogs \| summarize arg_min(TimeGenerated, *) by PodName`
                          value                   

  `any()`                 Return an arbitrary     `AppLogs \| summarize any(Message)`
                          value                   

  `take_any()`            Return an arbitrary     `AppLogs \| summarize take_any(Message) by PodName`
                          row/value               

  `variance()`            Calculate variance      `AppLogs \| summarize variance(DurationMs)`

  `stdev()`               Calculate standard      `AppLogs \| summarize stdev(DurationMs)`
                          deviation               
  -------------------------------------------------------------------------------------------------------------

Example: count errors per pod.

``` kusto
AppLogs
| where Level == "Error"
| summarize ErrorCount = count() by PodName
| sort by ErrorCount desc
```

## 8. Joining and combining tables

  --------------------------------------------------------------------------------------------------------
  Operator                Purpose                 Example
  ----------------------- ----------------------- --------------------------------------------------------
  `join`                  Combine rows using      `Pods \| join kind=inner (Events) on PodName`
                          matching keys           

  `lookup`                Enrich a large left     `Pods \| lookup kind=leftouter (NodeInfo) on NodeName`
                          table using a smaller   
                          right table             

  `union`                 Append rows from        `union AppLogs, AuditLogs`
                          multiple tables         

  `materialize()`         Cache a tabular         `let T = materialize(AppLogs); T \| count`
                          expression for reuse    

  `as`                    Name a tabular          `AppLogs \| as Logs \| where Level == "Error"`
                          expression              
  --------------------------------------------------------------------------------------------------------

### Common join kinds

  Join kind       Meaning
  --------------- --------------------------------------------------
  `inner`         Matching rows from both sides
  `innerunique`   Inner join; deduplicates the left-side join keys
  `leftouter`     All left rows plus matching right rows
  `rightouter`    All right rows plus matching left rows
  `fullouter`     All rows from both sides
  `leftanti`      Left rows with no matching right row
  `rightanti`     Right rows with no matching left row
  `leftsemi`      Matching left rows only
  `rightsemi`     Matching right rows only

Example:

``` kusto
Pods
| join kind=leftouter (
    Nodes
) on NodeName
| project PodName, NodeName, NodeStatus
```

## 9. String functions and operators

  -----------------------------------------------------------------------------------------------------------
  Function / operator     Purpose                 Example
  ----------------------- ----------------------- -----------------------------------------------------------
  `strcat()`              Concatenate strings     `print strcat("aks", "-cluster")`

  `strlen()`              Get string length       `print strlen("Kubernetes")`

  `substring()`           Extract part of a       `print substring("Kubernetes", 0, 4)`
                          string                  

  `toupper()`             Convert to uppercase    `print toupper("aks")`

  `tolower()`             Convert to lowercase    `print tolower("AKS")`

  `trim()`                Remove characters from  `print trim(" ", " AKS ")`
                          both ends               

  `trim_start()`          Remove characters from  `print trim_start(" ", " AKS")`
                          start                   

  `trim_end()`            Remove characters from  `print trim_end(" ", "AKS ")`
                          end                     

  `replace_string()`      Replace literal text    `print replace_string("pod-failed", "failed", "running")`

  `replace_regex()`       Replace regex matches   `print replace_regex("pod-123", @"[0-9]+", "ID")`

  `split()`               Split string into an    `print split("aks,pod,node", ",")`
                          array                   

  `strcat_array()`        Join array elements     `print strcat_array(dynamic(["aks","pod"]), "-")`
                          into a string           

  `extract()`             Extract a regex capture `print extract(@"pod-(\d+)", 1, "pod-123")`
                          group                   

  `extract_all()`         Extract all regex       `print extract_all(@"[0-9]+", "pod-12-node-34")`
                          matches                 

  `indexof()`             Find substring position `print indexof("kubernetes", "netes")`

  `reverse()`             Reverse a string        `print reverse("AKS")`

  `translate()`           Replace individual      `print translate("abc", "abc", "123")`
                          characters              

  `parse_url()`           Parse URL components    `print parse_url("https://example.com/api")`

  `parse_ipv4()`          Convert IPv4 address to `print parse_ipv4("192.168.1.1")`
                          numeric form            
  -----------------------------------------------------------------------------------------------------------

## 10. Datetime and timespan functions

  --------------------------------------------------------------------------------------------------------------------
  Function                          Purpose                 Example
  --------------------------------- ----------------------- ----------------------------------------------------------
  `now()`                           Current UTC datetime    `print now()`

  `ago()`                           Datetime relative to    `AppLogs \| where TimeGenerated > ago(1h)`
                                    now                     

  `datetime()`                      Create a datetime value `print datetime(2026-11-24)`

  `timespan()`                      Create a timespan value `print timespan(01:00:00)`

  `bin()`                           Round down into time    `AppLogs \| summarize count() by bin(TimeGenerated, 5m)`
                                    buckets                 

  `bin_at()`                        Bin relative to a fixed `print bin_at(now(), 1h, datetime(2026-11-24))`
                                    datetime                

  `startofday()`                    Start of day            `print startofday(now())`

  `endofday()`                      End of day              `print endofday(now())`

  `startofweek()`                   Start of week           `print startofweek(now())`

  `endofweek()`                     End of week             `print endofweek(now())`

  `startofmonth()`                  Start of month          `print startofmonth(now())`

  `endofmonth()`                    End of month            `print endofmonth(now())`

  `startofyear()`                   Start of year           `print startofyear(now())`

  `endofyear()`                     End of year             `print endofyear(now())`

  `datetime_diff()`                 Difference between      `print datetime_diff("minute", now(), ago(1h))`
                                    datetimes in a chosen   
                                    unit                    

  `format_datetime()`               Format a datetime       `print format_datetime(now(), "yyyy-MM-dd")`

  `dayofweek()`                     Get day of week as a    `print dayofweek(now())`
                                    timespan                

  `dayofmonth()`                    Get day of month        `print dayofmonth(now())`

  `getmonth()`                      Get month number        `print getmonth(now())`

  `getyear()`                       Get year                `print getyear(now())`

  `hourofday()`                     Get hour of day         `print hourofday(now())`

  `unixtime_seconds_todatetime()`   Convert Unix seconds to `print unixtime_seconds_todatetime(1700000000)`
                                    datetime                

  `datetime_utc_to_local()`         Convert UTC datetime to `print datetime_utc_to_local(now(), "US/Eastern")`
                                    local time              
  --------------------------------------------------------------------------------------------------------------------

## 11. Dynamic data and JSON

  --------------------------------------------------------------------------------------------------------------------------
  Function / operator     Purpose                 Example
  ----------------------- ----------------------- --------------------------------------------------------------------------
  `dynamic`               Create a dynamic value  `print d = dynamic({"pod":"api","status":500})`

  `parse_json()`          Parse JSON text         `print d = parse_json('{"pod":"api"}')`

  `todynamic()`           Convert input to        `print d = todynamic('{"pod":"api"}')`
                          dynamic                 

  `tostring()`            Convert value to string `print tostring(123)`

  `toint()`               Convert value to        `print toint("100")`
                          integer                 

  `tolong()`              Convert value to long   `print tolong("1000")`

  `todouble()`            Convert value to double `print todouble("12.5")`

  `tobool()`              Convert value to        `print tobool("true")`
                          boolean                 

  `gettype()`             Return dynamic value's  `print gettype(dynamic({"pod":"api"}))`
                          type                    

  `bag_keys()`            Return property names   `print bag_keys(dynamic({"pod":"api","status":500}))`

  `bag_pack()`            Create a property bag   `print bag_pack("pod","api","status",500)`

  `bag_unpack`            Expand property bag     `datatable(d:dynamic)[dynamic({"pod":"api"})] \| evaluate bag_unpack(d)`
                          into columns            

  `parse_json()` plus     Read a JSON property    `print d=parse_json('{"status":500}') \| project Status=d.status`
  property access                                 
  --------------------------------------------------------------------------------------------------------------------------

## 12. Parsing

  ------------------------------------------------------------------------------------------------------------------
  Operator / function     Purpose                 Example
  ----------------------- ----------------------- ------------------------------------------------------------------
  `parse`                 Extract fields using a  `AppLogs \| parse Message with "Pod:" PodName " Status:" Status`
                          pattern                 

  `parse-where`           Parse and discard rows  `AppLogs \| parse-where Message with "Pod:" PodName`
                          that do not match       

  `parse-kv`              Parse key-value text    `print parse_kv("pod=api status=500")`

  `extract()`             Extract a regex capture `AppLogs \| extend PodId=extract(@"pod-(\d+)", 1, Message)`

  `parse_json()`          Parse JSON text         `AppLogs \| extend Data=parse_json(Message)`

  `evaluate bag_unpack`   Expand dynamic          `AppLogs \| evaluate bag_unpack(Properties)`
                          properties              
  ------------------------------------------------------------------------------------------------------------------

## 13. Null, empty, and conditional functions

  ----------------------------------------------------------------------------------------------------------------------------------------------------
  Function                Purpose                 Example
  ----------------------- ----------------------- ----------------------------------------------------------------------------------------------------
  `isnull()`              Check for null          `AppLogs \| where isnull(Message)`

  `isnotnull()`           Check for non-null      `AppLogs \| where isnotnull(Message)`

  `isempty()`             Check for empty or null `AppLogs \| where isempty(Message)`
                          string                  

  `isnotempty()`          Check for non-empty     `AppLogs \| where isnotempty(Message)`
                          string                  

  `isnan()`               Check for NaN           `datatable(x:real)[real(nan)] \| where isnan(x)`

  `coalesce()`            Return first non-null   `AppLogs \| extend Text=coalesce(Message, "Unknown")`
                          value                   

  `iff()`                 Return one of two       `AppLogs \| extend Status=iff(DurationMs > 500, "Slow", "Normal")`
                          values based on         
                          condition               

  `iif()`                 Conditional expression  `AppLogs \| extend Status=iif(DurationMs > 500, "Slow", "Normal")`

  `case()`                Evaluate multiple       `AppLogs \| extend Status=case(DurationMs > 1000, "Critical", DurationMs > 500, "Slow", "Normal")`
                          conditions              
  ----------------------------------------------------------------------------------------------------------------------------------------------------

## 14. Math and conversion functions

  Function / operator   Purpose                   Example
  --------------------- ------------------------- ---------------------------
  `abs()`               Absolute value            `print abs(-10)`
  `round()`             Round to precision        `print round(12.567, 2)`
  `floor()`             Round down                `print floor(12.9)`
  `ceiling()`           Round up                  `print ceiling(12.1)`
  `sqrt()`              Square root               `print sqrt(25)`
  `pow()`               Raise to a power          `print pow(2, 3)`
  `log()`               Natural logarithm         `print log(10)`
  `log10()`             Base-10 logarithm         `print log10(100)`
  `exp()`               Exponential function      `print exp(1)`
  `rand()`              Random number             `print rand()`
  `sign()`              Sign of a number          `print sign(-10)`
  `isfinite()`          Check for finite number   `print isfinite(12.5)`
  `isinf()`             Check for infinity        `print isinf(real(null))`
  `toint()`             Convert to integer        `print toint("42")`
  `tolong()`            Convert to long           `print tolong("42000")`
  `todouble()`          Convert to real/double    `print todouble("42.5")`
  `tostring()`          Convert to string         `print tostring(42)`

## 15. Arrays and multi-value data

  -------------------------------------------------------------------------------------------------------------------------------
  Function / operator     Purpose                 Example
  ----------------------- ----------------------- -------------------------------------------------------------------------------
  `array_length()`        Get array length        `print array_length(dynamic([1,2,3]))`

  `array_concat()`        Combine arrays          `print array_concat(dynamic([1]), dynamic([2]))`

  `array_index_of()`      Find element index      `print array_index_of(dynamic(["api","worker"]), "api")`

  `array_sort_asc()`      Sort array ascending    `print array_sort_asc(dynamic([3,1,2]))`

  `array_sort_desc()`     Sort array descending   `print array_sort_desc(dynamic([3,1,2]))`

  `pack_array()`          Create an array         `print pack_array("api","worker")`

  `set_union()`           Combine distinct array  `print set_union(dynamic([1,2]), dynamic([2,3]))`
                          values                  

  `mv-expand`             Expand array elements   `print d=dynamic(["api","worker"]) \| mv-expand d`
                          into rows               

  `mv-apply`              Apply a subquery to     `print d=dynamic([1,2,3]) \| mv-apply x=d on (summarize total=sum(toint(x)))`
                          array elements          

  `strcat_array()`        Join array elements     `print strcat_array(dynamic(["a","b"]), ",")`
                          into a string           
  -------------------------------------------------------------------------------------------------------------------------------

## 16. Time-series analysis

  ----------------------------------------------------------------------------------------------------------------------------------------------------
  Function / operator       Purpose                 Example
  ------------------------- ----------------------- --------------------------------------------------------------------------------------------------
  `make-series`             Build a time-series     `AppLogs \| make-series Errors=count() default=0 on TimeGenerated from ago(1h) to now() step 5m`
                            array                   

  `series_decompose()`      Decompose a series into `print s=dynamic([1,2,3,4,5]) \| extend d=series_decompose(s)`
                            components              

  `series_outliers()`       Detect outliers         `print s=dynamic([1,2,3,100,2]) \| extend o=series_outliers(s)`

  `series_fit_line()`       Fit a linear trend      `print s=dynamic([1,2,3,4,5]) \| extend f=series_fit_line(s)`

  `series_stats()`          Calculate series        `print s=dynamic([1,2,3,4]) \| extend stats=series_stats(s)`
                            statistics              

  `series_fill_linear()`    Fill missing values     `print s=dynamic([1,real(null),3]) \| extend f=series_fill_linear(s)`
                            using linear            
                            interpolation           

  `series_fill_forward()`   Fill missing values     `print s=dynamic([1,real(null),3]) \| extend f=series_fill_forward(s)`
                            from previous values    
  ----------------------------------------------------------------------------------------------------------------------------------------------------

## 17. Other useful tabular operators

  --------------------------------------------------------------------------------------------------------------------------------------------------
  Operator                Purpose                 Example
  ----------------------- ----------------------- --------------------------------------------------------------------------------------------------
  `render`                Visualize query output  `AppLogs \| summarize count() by Level \| render piechart`

  `evaluate`              Invoke a query plugin   `AppLogs \| evaluate bag_unpack(Properties)`

  `facet`                 Explore values across   `AppLogs \| facet by Level`
                          columns                 

  `partition`             Run a subquery for each `AppLogs \| partition by PodName (top 5 by TimeGenerated)`
                          partition               

  `scan`                  Perform stateful        `AppLogs \| sort by TimeGenerated asc \| scan declare (n:long=0) with (step s: true => n=s.n+1)`
                          row-by-row processing   

  `reduce`                Cluster similar text    `AppLogs \| reduce by Message`
                          values into patterns    

  `top-nested`            Return hierarchical top `Sales \| top-nested 3 of Region by sum(Revenue), top-nested 2 of Product by sum(Revenue)`
                          values                  

  `fork`                  Run multiple query      `AppLogs \| fork (where Level == "Error") (where Level == "Warning")`
                          branches                

  `consume`               Consume rows without    `AppLogs \| consume`
                          returning them          
  --------------------------------------------------------------------------------------------------------------------------------------------------

Some advanced operators and `evaluate` plugins have service-specific
availability and syntax requirements. Check the documentation for the
target KQL service before using them in production.

## 18. Query statements

  -----------------------------------------------------------------------------------------------------------------------------------
  Statement                    Purpose                 Example
  ---------------------------- ----------------------- ------------------------------------------------------------------------------
  `let`                        Define a variable or    `let Env = "QA"; AppLogs \| where Environment == Env`
                               tabular expression      

  `set`                        Set query execution     `set query_take_max_records = 100; AppLogs`
                               options                 

  `declare query_parameters`   Declare typed query     `declare query_parameters (env:string); AppLogs \| where Environment == env`
                               parameters              
  -----------------------------------------------------------------------------------------------------------------------------------

## 19. DevOps and AKS troubleshooting examples

The following examples use a hypothetical `AppLogs` table. Replace it
with the actual table and column names in your Log Analytics workspace.

### 19.1 Find application errors

``` kusto
AppLogs
| where Level == "Error"
| project TimeGenerated, Namespace, PodName, Message
| sort by TimeGenerated desc
| take 100
```

### 19.2 Find errors in the last 24 hours

``` kusto
AppLogs
| where TimeGenerated > ago(24h)
| where Level == "Error"
| summarize ErrorCount = count()
```

### 19.3 Find pods generating the most errors

``` kusto
AppLogs
| where Level == "Error"
| summarize ErrorCount = count() by Namespace, PodName
| top 10 by ErrorCount desc
```

### 19.4 Find slow API requests

``` kusto
AppLogs
| where DurationMs > 1000
| project TimeGenerated, APIName, DurationMs, PodName
| sort by DurationMs desc
```

### 19.5 Calculate error percentage

``` kusto
AppLogs
| summarize
    TotalRequests = count(),
    FailedRequests = countif(Level == "Error")
| extend ErrorPercentage =
    round(100.0 * todouble(FailedRequests) / TotalRequests, 2)
```

### 19.6 Group errors into five-minute intervals

``` kusto
AppLogs
| where Level == "Error"
| summarize ErrorCount = count() by bin(TimeGenerated, 5m)
| render timechart
```

### 19.7 Find unique pods

``` kusto
AppLogs
| distinct Namespace, PodName
```

### 19.8 Find pods with more than ten errors

``` kusto
AppLogs
| where Level == "Error"
| summarize ErrorCount = count() by Namespace, PodName
| where ErrorCount > 10
| sort by ErrorCount desc
```

### 19.9 Extract HTTP 5xx responses from JSON messages

``` kusto
AppLogs
| extend Data = parse_json(Message)
| extend StatusCode = toint(Data.statusCode)
| where StatusCode between (500 .. 599)
| project TimeGenerated, PodName, StatusCode, Message
```

### 19.10 Calculate P95 response time by API

``` kusto
AppLogs
| summarize P95 = percentile(DurationMs, 95) by APIName
| sort by P95 desc
```

### 19.11 Find the latest event for each pod

``` kusto
AppLogs
| summarize arg_max(TimeGenerated, *) by Namespace, PodName
| project TimeGenerated, Namespace, PodName, Level, Message
| sort by TimeGenerated desc
```

### 19.12 Compare errors and warnings

``` kusto
AppLogs
| where TimeGenerated > ago(24h)
| summarize
    Errors = countif(Level == "Error"),
    Warnings = countif(Level == "Warning")
    by bin(TimeGenerated, 15m)
| render timechart
```

### 19.13 Find messages containing timeout or connection failures

``` kusto
AppLogs
| where TimeGenerated > ago(6h)
| where Message has_any ("timeout", "connection", "refused")
| project TimeGenerated, PodName, Message
| sort by TimeGenerated desc
```

### 19.14 Correlate application logs with Kubernetes events

``` kusto
AppLogs
| where TimeGenerated > ago(1h)
| join kind=leftouter (
    KubeEvents
    | where TimeGenerated > ago(1h)
) on PodName
| project TimeGenerated, PodName, Message, Reason, KubeEventTime = TimeGenerated1
```

> Join column names and timestamp column names depend on the source
> tables. Check the workspace schema and rename duplicate columns before
> using this pattern.

## 20. Recommended learning order

  -----------------------------------------------------------------------
  Stage                               Topics to master
  ----------------------------------- -----------------------------------
  1\. Fundamentals                    `where`, `project`, `take`,
                                      `count`, `distinct`, `sort`, `top`

  2\. Filtering                       `has`, `contains`, `in`, `between`,
                                      `matches regex`, `and`, `or`

  3\. Aggregation                     `summarize`, `countif`, `avg`,
                                      `sum`, `dcount`, `percentile`

  4\. Time analysis                   `ago`, `now`, `bin`,
                                      `datetime_diff`, `make-series`

  5\. Transformation                  `extend`, `parse`, `parse_json`,
                                      `mv-expand`, `bag_unpack`

  6\. Correlation                     `join`, `lookup`, `union`, `let`,
                                      `materialize`

  7\. Advanced analytics              `render`, `series_outliers`,
                                      `scan`, `partition`, `evaluate`
  -----------------------------------------------------------------------

## Official Microsoft documentation

-   [Kusto Query Language (KQL)
    overview](https://learn.microsoft.com/azure/data-explorer/kusto/query/)
-   [KQL quick
    reference](https://learn.microsoft.com/azure/data-explorer/kusto/query/kql-quick-reference)
-   [Query
    operators](https://learn.microsoft.com/azure/data-explorer/kusto/query/queries)
-   [Scalar
    functions](https://learn.microsoft.com/azure/data-explorer/kusto/query/scalarfunctions)
-   [Aggregation
    functions](https://learn.microsoft.com/azure/data-explorer/kusto/query/aggregation-functions)
-   [Time-series
    analysis](https://learn.microsoft.com/azure/data-explorer/kusto/query/time-series-analysis)

------------------------------------------------------------------------

**Suggested Git filename:** `kql-operators-cheat-sheet.md`
