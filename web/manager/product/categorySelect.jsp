<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String path = request.getContextPath();
    String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + path + "/";
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>选择商品类别</title>
    <base href="<%=basePath%>">
    <script src="resources/jquery/jquery-1.9.0.min.js" type="text/javascript"></script>
    <link href="resources/ligerUI/skins/Aqua/css/ligerui-all.css" rel="stylesheet" type="text/css">
    <link href="resources/ligerUI/skins/Gray/css/all.css" rel="stylesheet" type="text/css">

    <script src="resources/ligerUI/js/core/base.js" type="text/javascript"></script>
    <script src="resources/ligerUI/js/ligerui.all.js" type="text/javascript"></script>

    <link rel="stylesheet" href="resources/product/css/style.css"/>

</head>
<body>
<div class="contains">
    <!--商品分类-->
    <div class="wareSort clearfix">
        <ul id="sort1"></ul>
        <ul id="sort2" style="display: none;"></ul>
        <ul id="sort3" style="display: none;"></ul>
    </div>

    <div class="selectedSort">
        <b>您当前选择的商品类别是：</b>
        <i id="selectedSort"></i>
    </div>

    <div class="wareSortBtn">
        <input id="releaseBtn" type="button" value="下一步" disabled="disabled"/>
    </div>
    <script src="resources/product/js/jquery.sort.js"></script>
</div>
</body>
</html>
