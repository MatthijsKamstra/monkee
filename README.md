# monkee

![](icon.png)

Minimal static site generator

## default haxe used

- [templates](https://haxe.org/manual/std-template.html)
- markdown lib
- reading and writing

## speed

```
  │ ├── node
[node] done in 42ms
  │ ├── python
[python] done in 0ms
  │ ├── neko
Main.hx:41: [neko] done in 0ms
  │ ├── cpp
Main.hx:41: [cpp] done in 10ms
  │ ├── cs
haxelib run hxcs hxcs_build.txt --haxe-version 3407 --feature-level 1
Note: dmcs is deprecated, please use mcs instead!
Main.hx:41: [cs] done in 130ms

  │ ├── java
Main.hx:41: [java] done in 224ms
Note: Some input files use or override a deprecated API.
Note: Recompile with -Xlint:deprecation for details.
```

## python

`build_move.html` uses the export of pyton