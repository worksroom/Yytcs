<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.youguu.core.util.ParamUtil" %>
<%
    String path = request.getContextPath();
    String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + path + "/";
    int id = ParamUtil.CheckParam(request.getParameter("id"), 0);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <base href="<%=basePath%>">
    <title>添加运费模板</title>
    <meta content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" name="viewport">
    <script type="text/javascript" src="https://code.jquery.com/jquery-1.12.4.min.js"></script>

    <link href="resources/ligerUI/skins/Aqua/css/ligerui-all.css" rel="stylesheet" type="text/css">
    <link href="resources/ligerUI/skins/Gray/css/all.css" rel="stylesheet" type="text/css">
    <script src="resources/ligerUI/js/core/base.js" type="text/javascript"></script>
    <script src="resources/ligerUI/js/ligerui.all.js" type="text/javascript"></script>


    <script type="text/javascript">
        var groupicon = "resources/ligerUI/skins/icons/communication.gif";
        var form;
        var dialog = frameElement.dialog;

        $(function () {
            form = $("#form2").ligerForm({
                inputWidth: 170, labelWidth: 90, space: 10,
                fields: [
                    {
                        display: "模板ID",
                        name: "id",
                        newline: false,
                        type: "hidden"
                    },
                    {
                        display: "店铺ID",
                        name: "shopId",
                        newline: false,
                        type: "hidden"
                    },
                    {
                        display: "模板名称",
                        name: "name",
                        newline: false,
                        type: "text"
                    },{
                        display: "模板类别 ",
                        name: "type",
                        newline: true,
                        type: "select",
                        comboboxName: "typeComboBox",
                        options: {data: [
                            { id: '1', value: '1', text: '免邮' },
                            { id: '2', value: '2', text: '按件计费'}
                        ]}
                    },{
                        display: "邮费价格",
                        name: "price",
                        newline: true,
                        type: "text"
                    },{
                        display: "商品数量",
                        name: "num",
                        newline: true,
                        type: "text"
                    }
                ]
            });

            loadData();
        });

        function loadData(){
            $.ajax({
                cache: true,
                type: "POST",
                url:"manager/fareMould.do?method=getFareMould",
                data: {"id": "<%=id %>"},
                async: false,
                error: function(data) {
                    $.ligerDialog.tip({
                        title: '提示信息',
                        content: '获取信息失败'
                    });
                },
                success: function(data) {
                    form.setData(data);
                }
            });
        }

        function submitform() {
            return form.getData();
        }

    </script>

</head>
<body style="padding:0px;height: 90%">

<form id="form1" onsubmit="return false">
    <div id="form2" style="float: left;"></div>
</form>

</body>
</html>
