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
    <title>买家管理</title>

    <link href="resources/ligerUI/skins/Aqua/css/ligerui-all.css" rel="stylesheet" type="text/css">
    <link href="resources/ligerUI/skins/ligerui-icons.css" rel="stylesheet" type="text/css">
    <link href="resources/css/jquery-ui.min.css" rel="stylesheet" type="text/css">
    <link href="resources/css/ne.css" rel="stylesheet" type="text/css">
    <link href="resources/ligerUI/skins/Gray/css/all.css" rel="stylesheet" type="text/css">
    <script src="resources/jquery/jquery-1.9.0.min.js" type="text/javascript"></script>
    <script src="resources/ligerUI/js/core/base.js" type="text/javascript"></script>
    <script src="resources/ligerUI/js/ligerui.all.js" type="text/javascript"></script>
    <script src="resources/js/json2.js" type="text/javascript"></script>
    <script type="text/javascript">
        var grid;
        $(function () {
            grid = $("#maingrid").ligerGrid({
                checkbox: true,
                columns: [
                    {display: '仓库位置ID', name: 'id', align: 'left', width: 50, hide: true},
                    {display: '店铺ID', name: 'shopId', align: 'left', width: 100, minWidth: 60},
                    {display: '一级编码', name: 'fCode', minWidth: 150},
                    {display: '一级名称', name: 'fName', minWidth: 100},
                    {display: '二级编码', name: 'sCode', minWidth: 150},
                    {display: '二级名称', name: 'sName', minWidth: 100},
                    {display: '创建时间', name: 'createTime', minWidth: 140},
                    {display: '修改时间', name: 'updateTime', minWidth: 140}
                ],
                dataAction: 'server',
                url: 'manager/storeLocation.do?method=storeLocationList',
                usePager: false,
                pageSize: 20,
                rownumbers: true,
                width: '100%',
                height: '100%',
                toolbar: {
                    items: [
                        { text: '新增', click: addData, icon: 'add' },
                        { text: '修改', click: updateData, icon: 'add' },
                        { text: '删除', click: deleteData, icon: 'delete' }
                    ]
                }
            });


            $("#pageloading").hide();
        });

        function addData(){
            $.ligerDialog.open({
                url: 'manager/product/storeLocationAdd.jsp', height: 400, width: 300, buttons: [
                    {
                        text: '提交保存', onclick: function (item, dialog) {
                        var formData = dialog.frame.submitform();

                        $.ajax({
                            cache: true,
                            type: "POST",
                            url:"manager/storeLocation.do?method=saveStoreLocation",
                            data: formData,
                            async: false,
                            error: function(data) {
                                $.ligerDialog.tip({
                                    title: '提示信息',
                                    content: data.message
                                });
                            },
                            success: function(data) {
                                dialog.close();
                                grid.reload();
                                $.ligerDialog.tip({
                                    title: '提示信息',
                                    content: data.message
                                });
                            }
                        });
                    }, cls: 'l-dialog-btn-highlight'
                    },
                    {
                        text: '取消', onclick: function (item, dialog) {
                        dialog.close();
                    }
                    }
                ], isResize: true
            });
        }

        function updateData(){
            var row = grid.getSelectedRow();
            $.ligerDialog.open({
                url: 'manager/product/storeLocationUpdate.jsp?id='+row.id, height: 400, width: 300, buttons: [
                    {
                        text: '提交保存', onclick: function (item, dialog) {
                        var formData = dialog.frame.submitform();

                        $.ajax({
                            cache: true,
                            type: "POST",
                            url:"manager/storeLocation.do?method=updateStoreLocation",
                            data: formData,
                            async: false,
                            error: function(data) {
                                $.ligerDialog.tip({
                                    title: '提示信息',
                                    content: data.message
                                });
                            },
                            success: function(data) {
                                dialog.close();
                                grid.reload();
                                $.ligerDialog.tip({
                                    title: '提示信息',
                                    content: data.message
                                });
                            }
                        });
                    }, cls: 'l-dialog-btn-highlight'
                    },
                    {
                        text: '取消', onclick: function (item, dialog) {
                        dialog.close();
                    }
                    }
                ], isResize: true
            });
        }

        function deleteData(){
            var rows = grid.getSelecteds();

            var selectIds = new Array();
            $(rows).each(function () {
                selectIds.push(this.id);
            });

            $.ligerDialog.confirm('确定要删除吗', function (yes) {
                if(yes==true){
                    $.ajax({
                        cache: true,
                        type: "POST",
                        url:"manager/storeLocation.do?method=deleteStoreLocation&ids="+selectIds,
                        async: false,
                        error: function(data) {
                            $.ligerDialog.tip({
                                title: '提示信息',
                                content: data.message
                            });
                        },
                        success: function(data) {
                            grid.reload();
                            $.ligerDialog.tip({
                                title: '提示信息',
                                content: data.message
                            });
                        }
                    });
                }
            });
        }

    </script>

</head>
<body style="overflow:hidden">


<div class="l-loading" style="display:block" id="pageloading"></div>
<a class="l-button" style="width:120px;float:left; margin-left:10px; display:none;" onclick="deleteRow()">删除选择的行</a>


<div class="l-clear"></div>

<div id="maingrid"></div>

<div style="display:none;">

</div>
</body>
</html>
