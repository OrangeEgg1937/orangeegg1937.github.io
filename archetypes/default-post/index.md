---
title: '{{ replace .File.ContentBaseName `-` ` ` | title }}'
date: '{{ .Date }}'
description: "Sample description"
summary: "Sample summary"
draft: true # Remove this line to publish the page

categories:
    - Example
tags:
    - Example

# Featured image of the page.
image: "https://example.com/image.jpg"

math: true
toc: true

# Additional settings for the page
# https://stack.jimmycai.com/writing/frontmatter

# Additional CSS styles for taxonomy term badge that appears in article page.
# Currently only background (background of the badge) and color (text color) are supported.
style: []

# Keywords of the page. Useful for SEO.
keywords:
  - "keyword1"
  - "keyword2"

---