<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String path = request.getContextPath();
    String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + path + "/";
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <base href="<%=basePath%>">
    <meta http-equiv="Content-Language" content="zh-CN"/>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <meta name="renderer" content="webkit">
    <title>货品管理</title>

    <link href="resources/ligerUI/skins/Aqua/css/ligerui-all.css" rel="stylesheet" type="text/css">
    <link href="resources/ligerUI/skins/ligerui-icons.css" rel="stylesheet" type="text/css">
    <link href="resources/css/jquery-ui.min.css" rel="stylesheet" type="text/css">
    <link href="resources/css/ne.css" rel="stylesheet" type="text/css">
    <link href="resources/css/input.css" rel="stylesheet" type="text/css">
    <link href="resources/ligerUI/skins/Gray/css/all.css" rel="stylesheet" type="text/css">
    <script src="resources/jquery/jquery-1.9.0.min.js" type="text/javascript"></script>
    <script src="resources/css/jquery-ui.min.js" type="text/javascript"></script>
    <script src="resources/jquery/jquery.form.js" type="text/javascript"></script>
    <script src="resources/ligerUI/js/core/base.js" type="text/javascript"></script>
    <script src="resources/ligerUI/js/ligerui.all.js" type="text/javascript"></script>
    <script src="resources/js/json2.js" type="text/javascript"></script>
    <script type="text/javascript">
        var grid;
        $(function () {
            grid = $("#maingrid").ligerGrid({
                checkbox: true,
                columns: [
                    {display: '货品ID', name: 'id', align: 'left', width: 60},
                    {display: '货品名称', name: 'name', align: 'left', width: 100, minWidth: 60},
                    {display: '货品描述', name: 'des', minWidth: 100},
                    {display: '所属类别', name: 'classId', minWidth: 100},
                    {display: '货品状态', name: 'status', minWidth: 100, render: function (item) {
                        var statusTxt = "其他"
                        if(item.status==99){
                            statusTxt = "待审"
                        } else if(item.status==1){
                            statusTxt = "通过"
                        } else {
                            statusTxt = "其他"
                        }
                        return statusTxt;
                    }},
                    {display: '货品照片', name: 'img', minWidth: 100},
                    {display: '创建时间', name: 'createTime', minWidth: 140},
                    {display: '修改时间', name: 'updateTime', minWidth: 140}
                ],
                dataAction: 'server',
                url: 'manager/goods.do?method=mallGoodsList',
                pageSize: 20,
                rownumbers: true,
                width: '100%',
                height: '100%',
                toolbar: {
                    items: [
                        { text: '修改', click: updateData, icon: 'add' }
                    ]
                }
            });

            $("#pageloading").hide();


        });

        function updateData(){
            var row = grid.getSelectedRow();
            alert(row.id);
            parent.f_addTab("tab_goods_"+row.id, row.name, "manager/product/updatePublishProduct.jsp?goodsId="+row.id+"&categoryId="+row.classId);
        }

        function doserch(){
            var serchtxt = $("#serchform :input").fieldSerialize();
            $.ligerDialog.waitting('数据查询中,请稍候...');
            grid._setUrl("manager/goods.do?method=mallGoodsList&" + serchtxt);
            grid.loadData(true);
            $.ligerDialog.closeWaitting();

        }

        function doclear() {
            $("input:hidden", "#serchform").val("");
            $("input:text", "#serchform").val("");
            $(".l-selected").removeClass("l-selected");
        }


    </script>

</head>
<body style="overflow:hidden">


<div class="l-loading" style="display:block" id="pageloading"></div>
<a class="l-button" style="width:120px;float:left; margin-left:10px; display:none;" onclick="deleteRow()">删除选择的行</a>


<div class="l-clear"></div>

<div class="az">
    <form id='serchform'>
        <table style='width: 500px' class="bodytable1">
            <tr>
                <td>
                    <div style='width: 60px; text-align: right; float: right'>货品名称：</div>
                </td>
                <td>
                    <input type='text' id='name' name='name' style="width:80px"/>
                </td>

                <td>
                    <div style='width: 60px; text-align: right; float: right'>货品状态：</div>
                </td>
                <td>
                    <input type='text' id='status' name='status' style="width:80px"/>
                </td>
                <td>
                    <input id='Button2' type='button' value='重置' style='width: 80px; height: 24px' onclick="doclear()" />
                    <input id='Button1' type='button' value='搜索' style='width: 80px; height: 24px' onclick="doserch()" />
                </td>

            </tr>
        </table>
    </form>
</div>

<div id="maingrid"></div>

<div style="display:none;"></div>
</body>
</html>
