<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.youguu.core.util.ParamUtil" %>
<%
    String path = request.getContextPath();
    String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + path + "/";
    int orderId = ParamUtil.CheckParam(request.getParameter("orderId"), 0);
    String totalMoney = ParamUtil.CheckParam(request.getParameter("totalMoney"), "");
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <base href="<%=basePath%>">
    <title>修改订单价格</title>
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
                        display: "订单ID",
                        name: "orderId",
                        newline: false,
                        readonly: true
                    },
                    {
                        display: "支付金额",
                        name: "totalMoney",
                        newline: false
                    }
                ]
            });

            loadData();
        });

        function loadData(){
            form.setData({"orderId": <%=orderId%>, "totalMoney": <%=totalMoney%>});
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