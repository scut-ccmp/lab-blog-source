+++
title = "内容的发布与格式"
Description = "该说明文档中文章的格式与trick"
date = 2018-10-15
author = "unkcpz, hecc"
Tag = ["site"]
Categories = ["tutorial"]
+++

## 内容的发布与语法格式

该文主要内容为给出在本网站中发布的内容所要遵循的格式，有需要发布文章的同学和老师可以按照该内容准备好
`.md`文件用于发布。`Markdown`格式简单，易于编辑和修改，可以对特定的公式和代码块进行格式处理和
高亮，是非常简单易用的文本发布格式。

这篇post的源代码在[source-code](https://raw.githubusercontent.com/scut-ccmp/lab-blog-source/master/content/posts/how-to-post.md)处查看。

### `markdown`的语法和亮片

具体使用的详情请参考[md tutorial](https://www.markdowntutorial.com/)， [md official](https://daringfireball.net/projects/markdown/)。
下面只介绍最为常用的一些模式。

### 公式的编辑

#### 内嵌公式

使用一下命令输入内嵌公式，这种方式依赖于 [yihui-mathjs](https://yihui.name)提供的js脚本。

```markdown
内嵌公式`$\alpha + \beta = \frac{1}{\sqrt{x_0}}$`
```

得到下列内容：

{内嵌公式`$\alpha + \beta = \frac{1}{\sqrt{x_0}}$`}

#### 独立公式

```markdown
独立公式:

`$$\frac{\partial L}{\partial q} - \frac{d}{dt}\frac{\partial L}{\partial \dot{q}} = 0$$`
```

得到下列内容：

{
独立公式:

`$$\frac{\partial L}{\partial q} - \frac{d}{dt}\frac{\partial L}{\partial \dot{q}} = 0$$`
}

### 代码的编辑

代码部分通过特有的css样式装饰，以区别与普通内容，同时支持原格式的缩进和特定语言的高亮。
所需要的技术依赖于`markdown`的内容转换和`pygments`的高亮支持。

#### python代码

```python
# This is a hello name
def hello(name):
  print("hello {:s}".format(name))
  return
```

#### matlab代码

```matlab
% --- Executes on button press in load_img2.
function load_img2_Callback(hObject, eventdata, handles)
% hObject    handle to load_img2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Load and display second image from a directory
[img2_name, img2_pathname] = uigetfile({'*.jpg;*.png;*.bmp'}, 'Select an image file');
if (isequal(img2_name,0) || isequal(img2_pathname,0))
    warndlg('You need to select an image.', 'Please select images.');
else
    axes(handles.axes2);
    hold off;
    full_img2_name = fullfile(img2_pathname, img2_name);
    img2 = imreadAutoRot(full_img2_name);
    imshow(img2);
    setappdata(handles.axes2, 'axes2Image', img2);

    % Prepare selection field for plotting (plot it invisible for the time
    % being)
    hold on;
    rectangle_handle2 = rectangle('Position', [0 0 1 1], 'Visible', 'off');
    setappdata(handles.axes2, 'axes2Rectangle', rectangle_handle2);
end
```

#### golang代码

```go
// file: primes.go
// package primes generate prime numbers
package primes

func generatePrimes(m int) []int {
	_ = m
	return []int{1, 2}
}
```
