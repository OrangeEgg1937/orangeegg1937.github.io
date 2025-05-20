---
title: 簡單BongoCat動畫 with Arduino
description: 利用按鈕去轉換螢幕顯示的圖片
date: 2024-01-20 20:28:00+0800
slug: arduino-bongo-cat
categories:
    - Arduino
tags:
    - BongoCat
    - I2C
    - OLED
    - Arduino
keywords:
    - Arduino
    - BongoCat
    - I2C
    - OLED
    - Arduino

image: src/cover.png
---
# **Project repo here: [Code](https://github.com/OrangeEgg1937/ArduinoBongoCatOLED)**

## 前言

話說在某一天，有位友人發送了這個貼文給我
{{< instagram C5qtH2cLLbm >}}
當時看完之后感覺幾有趣，於是自己根據這張貼文去嘗試重現出來

## 分析

首先從圖片中可以大概了解當中必要的元件：MCU、顯示用的螢幕以及按鈕。

工作原理大概就是「透過按鈕去轉換顯示在螢幕上的圖片」，因此可以分為以下幾個步驟去實現：

1. Hardware Setup (MCU＋螢幕)
2. Software (顯示圖片的program)
   - 2.1. 圖片準備
   - 2.2. 控制按鈕去轉換圖片

## Hardware Setup (MCU＋螢幕)

{{< figure src="src/connection.png" alt="" width="800px" >}}

- 1x Arduino UNO
- 2x Button
- 1x SSD1306 OLED (0.96")

螢幕的通訊方法這裡將會使用I2C

## Sofware

因為採用SSD1306，所以可以直接用Adafruit SSD1306 Library，節省了寫I2C connection以及顯示螢幕像素的部分。

```c
#define SCREEN_WIDTH  128  // OLED display width, in pixels
#define SCREEN_HEIGHT 64   // OLED display height, in pixels
#define OLED_RESET    -1   // Reset pin # (or -1 if sharing Arduino reset pin)

// Declaration for an SSD1306 display connected to I2C (SDA, SCL pins)
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);

//  ------------------- For i2c -------------------
//  SSD1306_SWITCHCAPVCC = generate display voltage from 3.3V internally
  if(!display.begin(SSD1306_SWITCHCAPVCC, 0x3C)) {
    Serial.println(F("SSD1306 allocation failed"));
    for(;;); // Don't proceed, loop forever
  }
```

可能需要注意的是i2c address以及Arduino Pin位置（正常情況下應該都是0x3C）

### 圖片準備

SSD1306有幾個不同尺寸的型號，根據型號的尺寸，展示圖片的範圍也會有所不同。而我所使用的尺寸是128x64，為了方便設計，圖片的原生尺寸也設定為128x64。

{{< figure src="src/drawing.png" alt="" width="800px" >}}

然后再繪製4幅不同狀態的圖片（leftBtnOnClick, rightBtnOnClick, both, idle）

{{< figure src="src/pic_all.jpg" alt="" width="800px" >}}

### 將圖片import進去program

將圖片export變成bitmap，利用LCD Assistant輸出成byte array。（詳細的工作原理之后可能再補充一下）

關於LCD Assistant使用方法，可以參考我在網上找到的：
[＜Step By Step系列 - 番外篇 OLED圖片取檔方法, 使用LCD Assistant＞](https://nhs-tw.blogspot.com/2015/11/step-by-step-oled-lcd-assistant.html)

之後我們將結果貼上在主程式裏面
{{< figure src="src/byte_array_01.jpg" alt="" width="800px" >}}

需要注意的是如果我們直接貼上的話，應該會顯示以下錯誤：
{{< figure src="src/max_error.jpg" alt="" width="800px" >}}
這個原因是因為Arduino的dynamic memory(RAM)沒有足夠空間放我們的圖片，dynamic memory通常在MCU上面所擁有的空間都比較少(而且珍貴)，而我們的圖片是一個非常大的檔案。

因為我們的圖片通常是是一個常數不會變的東西，所以我們可以將圖片的資料放在Flash memory，因此我們需要加一個modifier "PROGMEM"在這個variable上面：

```c
const unsigned char bongoCat_idle [1024] PROGMEM = {...};
```

詳細的使用可以參考官方的文章：[Arduino - PROGMEM](https://www.arduino.cc/reference/en/language/variables/utilities/progmem/)

之后圖片就可以順利import進去program裡面了！
{{< figure src="src/ok.png" alt="" width="800px" >}}

### 按鈕控制

控制方面，可以想像成是一個簡單的state machine，望下按鈕的瞬間去render不同的圖片

```C
  // if both button cliecked, draw both
  if (leftBtnState == LOW && rightBtnState == LOW) {
    display.drawBitmap(0, 0, bongoCat_bothBtn, 128, 64, WHITE);
  } else if(leftBtnState == LOW) {
    display.drawBitmap(0, 0, bongoCat_leftBtn, 128, 64, WHITE);
  } else if(rightBtnState == LOW) {
    display.drawBitmap(0, 0, bongoCat_rightBtn, 128, 64, WHITE);
  } else {
    display.drawBitmap(0, 0, bongoCat_idle, 128, 64, WHITE);
  }
```

## 最終成果

{{< figure src="src/result.png" alt="" width="800px" >}}
