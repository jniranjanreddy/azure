
## Basics - https://www.youtube.com/watch?v=A0jAeGf2zUQ
```
https://www.youtube.com/watch?v=paAYgjNITik&list=PLQxXvsb9gsJCg2y13f_5pF3n539VGN0Ju
https://www.youtube.com/watch?v=ZKFiJ4aTnts&list=PL4z_hOgrhWyCCSQQhaka9MO3hswfFUFeq
```
## Kusto Query Language (KQL):
```

Application Insights
availabilityResults
browserTimings
customEvents
customMetrics
dependencies
exceptions
pageViews
performanceCounters
requests
traces
```


## Traces
```
requests
| where resultCode != 200
| where resultCode != 300

```
