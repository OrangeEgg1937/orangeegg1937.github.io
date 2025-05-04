---
title: Basic smali code
description: personal note
date: 2024-10-03 14:13:00+0800
categories:
    - Android
    - smali
tags:
    - note
---
## Data types

| Type | Description | Size (bytes) | Size (bits) |
| --- | --- | --- | --- |
| V | void | 0 | 0 |
| Z | boolean | 1 | 1 |
| B | byte | 1 | 8 |
| S | short | 2 | 16 |
| C | char | 2 | 16 |
| I | int | 4 | 32 |
| J | long | 8 | 64 |
| F | float | 4 | 32 |
| D | double | 8 | 64 |
| L | reference | 4 | 32 |

- For object, it will follow the class definition in the .class file. For example, a class `android.widget.TextView` will be `Landroid/widget/TextView;` in Smali.

- For array, it will adding a `[` in front of the type, number of `[` is the dimension of the array. For example, a `int[]` will be `[I` in Smali; a `int[][]` will be `[[I`.

## Register and variable/member

For all registers, the size of the register is 4 bytes (32 bits).

### Parameter register and non-parameter register

|  | Size | Prefix |
| --- | --- | --- |
| Parameter register | no. of param | p (e.g: p0, p1, p2, ...) |
| non-parameter register | .locals [num] / .registers [total] - no. of param | v (e.g: v0, v1, v2, ...) |

> For Parameter register, in non-static method, the first parameter register is `p1`, because `p0` the reference to the object (`p0` = `this`). In static method, the first parameter register is `p0`.

### Initialize local variable with immediate value

`const(/4/16) {reg}, {value}`. For 64-bit, use `const-wide`.

> Complier may optimize the const to a smaller value. Like `int i = 0` may be optimized to `const/4 v0, 0x0`.

For example, we want to initialize `a = 10`.

```smali
const/16 v0, 0xa
```

### Constant Member/Field

`const-string {reg}, {string}`.

### Naming

When a method is invoked, the parameters to the method are placed into the last n registers.

Consider the following method:

```java
// obj1.java
int add_magic(int a, int b) {
    if (a > 10) return a + b;
    return 0;
}
```

Smali code:

```smali
# obj1.java
.method private add_magic(II)I
    .locals 1

    const/16 v0, 0xa

    if-le p1, v0, :cond_0

    add-int/2addr p1, p2

    goto :goto_0

    :cond_0
    const/4 p1, 0x0

    :goto_0
    return p1
.end method
```

In this example, we known that
| Register | Param/Var name in method |  
| --- | --- |
| v0 | `c` |
| p0 | `this` |
| p1 | `a` |
| p2 | `b` |

## Method

Basic definition:

```smali
# ObjectName;->MethodName(ParameterTypes)ReturnType
Lpackage/name/obj1;->get(III)Z
```

It is equal to the following in java:

```java
// obj1.java
boolean get(int a, int b, int c)
```

## Method Call

The basic syntax is `invoke{-method-type} {parameters}, method+returnType`.

| Command | Description |
| --- | --- |
| invoke-virtual | Non-private instance method |
| invoke-static | Static method |
| invoke-direct | Constructor or private method |
| invoke-super | Superclass method |
| invoke-interface | Interface method |

Example:

```java
// obj1.java
public int foo();
private void bar(int a, int b);
static void baz();
```

```smali
# obj1.java
invoke-virtual {}, Lpackage/name/obj1;->foo()I
invoke-direct {p0, v1, v2}, Lpackage/name/obj1;->bar(II)V
invoke-static {}, Lpackage/name/obj1;->baz()V
```

### Assign the result of the retrun value to a variable

Basic syntax is `move-result [register]`

| Command | Description |
| --- | --- |
| move-result | Move the return value to a register |
| move-result-wide | Move the return value to a register (64-bit) |
| move-result-object | Move the return value to a register (object) |

Example:

```smali
invoke-virtual {p0}, Lpackage/name/obj1;->foo()I
move-result v0
```

## Basic command for smali

### Variable assignment

For get/put, basic syntax is `{command} {src}, {dest}, {offset}`.

| Command | Description | Java code | Smali code |
| --- | --- | --- | --- |
| move | Move value from one register to another | `a = b` | `move v0, v1` |
| put | Assign value | `int a = b` | `iput v0, p0, Lcom/example/demo/MainActivity;->a:I` |
| get | Get value | `a` | `iget v0, p0, Lcom/example/MainActivity;->a:I` |

> For get and set, there is (i/s)set/put for static variable or instance variable.

### Conditional jump

Syntax is `if-{condition} {regA}, {regB}: {label}`

Example:

```Java
// p1 = i, v0 = 10, le is less than or equal to
    private int add_magic(int i, int i2) {
        if (i <= 10) { // if-le p1, v0, :cond_6
            return 0;
        }
        return i + i2;
    }
```

## Reference and detail command description

[Smali Github Wiki](https://github.com/JesusFreke/smali/wiki)

[Smali Register](https://github.com/JesusFreke/smali/wiki/Register)

[Smali Instruction](https://source.android.com/docs/core/runtime/dalvik-bytecode#instructions)

[apk 反编译基础](https://github.com/JnuSimba/AndroidSecNotes/blob/master/Android%E9%80%86%E5%90%91%E5%9F%BA%E7%A1%80/apk%20%E5%8F%8D%E7%BC%96%E8%AF%91%E5%9F%BA%E7%A1%80.md)

[Smali语法基础 - 叫我大表哥](https://www.cnblogs.com/songzhixue/p/12027822.html)

[Smali Example (乱码三千)](https://code.newban.cn/169.html)
