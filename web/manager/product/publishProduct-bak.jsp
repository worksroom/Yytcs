<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.youguu.core.util.ParamUtil" %>
<%
    String path = request.getContextPath();
    String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + path + "/";

    int categoryId = ParamUtil.CheckParam(request.getParameter("categoryId"), 0);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <base href="<%=basePath%>">
    <title>发布宝贝页面</title>
    <script src="resources/jquery/jquery-1.9.0.min.js" type="text/javascript"></script>
    <link href="resources/css/input.css" rel="stylesheet" type="text/css">
    <link href="resources/ligerUI/skins/Aqua/css/ligerui-all.css" rel="stylesheet" type="text/css">
    <link href="resources/ligerUI/skins/Gray/css/all.css" rel="stylesheet" type="text/css">

    <script src="resources/ligerUI/js/core/base.js" type="text/javascript"></script>
    <script src="resources/ligerUI/js/ligerui.all.js" type="text/javascript"></script>
    <script src="resources/js/YYT.js" type="text/javascript"></script>

    <link href="resources/swf/swfupload-default.css" rel="stylesheet"type="text/css" />
    <script type="text/javascript" src="resources/swf/swfupload.js"></script>
    <script type="text/javascript" src="resources/swf/handlers.js"></script>
    <link rel="stylesheet" href="resources/product/css/style.css"/>
    <script src="resources/jquery/jquery.form.js" type="text/javascript"></script>
    <script src="resources/js/json2.js" type="text/javascript"></script>
    <link href="resources/sku/liandong.css" rel="stylesheet"/>
    <script type="text/javascript">
        var grid;
        var prodata;
        var proKey = new Array();
        var proSaleKey = new Array();

        $(function () {
//            $.metadata.setType("attr", "validate");
//            XHD.validate($(form1));
            $("form").ligerForm();

            //初始化商品属性区域
            initProductPro();

            //初始化商品销售属性区域
            initProductSalePro();

            $('#pro_11').ligerComboBox({
                width: 200
            });

            if (getparastr("cid")) {
                loadForm(getparastr("cid"));
            }
            if (getparastr("Customer_id")) {
                $.ajax({
                    type: "GET",
                    url: "CRM_Customer.form.xhd", /* 注意后面的名字对应CS的方法名称 */
                    data: {cid: getparastr("Customer_id"), rnd: Math.random()}, /* 注意参数的格式和名称 */
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (result) {
                        var obj = eval(result);
                        for (var n in obj) {
                            if (obj[n] == null)
                                obj[n] = "";
                        }
                        //alert(obj.constructor); //String 构造函数
                        $("#T_company").val(obj.Customer);
                        $("#T_company_val").val(obj.id);
                        $("#T_company").ligerGetComboBoxManager().setReadOnly();
                    }
                });
            }


            grid = $("#maingrid").ligerGrid({
                checkbox: true,
                columns: [
                    {display: '颜色', name: 'color', align: 'left', width: 60},
                    {display: '尺码', name: 'size', align: 'left', width: 60},
                    {display: '价格', name: 'price', minWidth: 60,editor: { type: 'text' }},
                    {display: '市场价', name: 'marketPrice', minWidth: 60,editor: { type: 'text' }},
                    {display: '库存', name: 'storage', minWidth: 60,editor: { type: 'text' }}
                ],
                dataAction: 'server',
                url: 'manager/buyer.do?method=buyerList',
                usePager: false,
                rownumbers: true,
                width: '100%',
                height: 200,
                enabledEdit: true, clickToEdit: false, isScroll: false,
                toolbar: {
                    items: [
                        { text: '生成SKU', click: addRowData, icon: 'add' },
                        { text: '保存', click: saveData, icon: 'add' }
                    ]
                }
            });

            /**
             * 给提交审核按钮绑定提交事件
             */
            $("#releaseBtn").click(function () {
                alert("click");
                $(this).ajaxSubmit({
                    type: "post",  //提交方式
                    dataType: "json", //数据类型
//                data: myData,//自定义数据参数，视情况添加
                    url: "manager/product.do?method=save", //请求url
                    success: function (data) { //提交成功的回调函数
                        alert(data.message);
                    }
                });
            });
        });


        function addRowData() {
            $(proSaleKey).each(function(){
                var chk_value =[];
                $('input[name="'+this+'"]:checked').each(function(){
                    chk_value.push($(this).val());
                });
                alert(chk_value);
            });


            var color = liger.get("checkboxlist1").getValue();
            var size = liger.get("checkboxlist2").getValue();
            alert("color="+color+", size="+size);

            var rowdata = {"color": color, "size": size, "price": "", "marketPrice": "", "storage": ""};
            grid.addEditRow(rowdata);
        }

        /**
         * 保存SKU
         */
        function saveData(){

        }



        function f_save() {
            if ($(form1).valid()) {
                var sendtxt = "&Action=save&contact_id=" + getparastr("cid");
                return $("form :input").fieldSerialize() + sendtxt;
            }
        }

        function loadForm(oaid) {
            $.ajax({
                type: "GET",
                url: "CRM_Contact.form.xhd", /* 注意后面的名字对应CS的方法名称 */
                data: {id: oaid, rnd: Math.random()}, /* 注意参数的格式和名称 */
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (result) {
                    var obj = eval(result);
                    for (var n in obj) {
                        if (obj[n] == "null" || obj[n] == null)
                            obj[n] = "";
                    }
                    $("#T_company_val").val(obj.C_customerid);
                    $("#T_company").val(obj.C_customername);
                    $("#T_contact").val(obj.C_name);
                    if (obj.C_birthday){
                        $("#T_birthday").val(obj.C_birthday.split(" ")[0]);
                    }
                    $("#T_dep").val(obj.C_department);
                    $("#T_position").val(obj.C_position);
                    $("#T_tel").val(obj.C_tel);
                    $("#T_mobil").val(obj.C_mob);
                    $("#T_fax").val(obj.C_fax);
                    $("#T_email").val(obj.C_email);
                    $("#T_qq").val(obj.C_QQ);
                    $("#T_add").val(obj.C_add);
                    $("#T_hobby").val(obj.C_hobby);
                    $("#T_remarks").val(obj.C_remarks);

                    $("#T_sex").ligerGetComboBoxManager().selectValue(obj.C_sex);
                }
            });

        }

        function remotesite() {
            var url = "CRM_Customer.validate.xhd?T_cid=" + getparastr("cid") + "&rnd=" + Math.random();
            return url;
        }

        var contextPath = "<%=basePath%>";
        function startLoad() {
            var url = contextPath+"/manager/swfupload.do?method=upload"; //处理上传的servlet
            var sizeLimit = "1 MB";// 文件的大小  注意: 中间要有空格
            var types = "*.jpg;*.jpeg;*.gif"; //注意是 " ; " 分割
            var typesdesc = "web iamge file"; //这里可以自定义
            var uploadLimit = 20;  //上传文件的 个数
            initSwfupload(url, sizeLimit, types, typesdesc, uploadLimit);
        }


        /**
        * 初始化商品属性区域
         */
        function initProductPro(){
            prodata = "";
            $.ajax({
                cache: true,
                type: "POST",
                url:"manager/product.do?method=loadProList",
                data:{"classId": <%=categoryId %>},
                async: false,
                error: function(data) {
                    $.ligerDialog.tip({
                        title: '提示信息',
                        content: data.message
                    });
                },
                success: function(data) {

                    var prostr = "";
                    if(data.status=="0000" && data.result.length>0){
                        prodata = data.result;//全局变量赋值
                        $(data.result).each(function(){
                            var pro_id = this.id;
                            prostr += '<tr>';
                            prostr += '<td>';
                            prostr += '<div style="text-align: right; float: right">'+this.name+'：</div>';
                            prostr += '</td>';
                            prostr += '<td colspan="5">';
                            if(this.isMultiple){//多选
                                proKey.push("ch_pro_"+pro_id);
                                prostr += '<div>';

                                $(this.list).each(function(){
                                    prostr += '<label><input type="checkbox" name="ch_pro_'+pro_id+'" value="'+this.name+'" />'+this.name+'</label>';
                                });

                                prostr += '</div>';
                            } else {//单选
                                prostr += '<div>';
                                prostr += '<select id="pro_'+this.id+'">';

                                $(this.list).each(function(){
                                    prostr += '<option value ="value_'+this.id+'">'+this.name+'</option>';
                                });

                                prostr += '</select>';
                                prostr += '</div>';
                            }

                            prostr += '</td>';
                            prostr += '</tr>';
                        });


                        $("#first").after(prostr);
                    } else {

                    }

                }
            });
        }

        /**
        * 初始化商品销售属性区域
         */
        function initProductSalePro(){
            var prostr = "";
            $(prodata).each(function(){
                var pro_id = this.id;
                //是否是销售属性，非销售属性不处理
                if(this.isSku!=1){
                    return true;
                }

                prostr += '<tr>';
                prostr += '<td>';
                prostr += '<div style="text-align: right; float: right">'+this.name+'：</div>';
                prostr += '</td>';
                prostr += '<td colspan="5">';

                if(this.isMultiple){//多选
                    proSaleKey.push("ch_sale_"+pro_id);
                    prostr += '<div>';

                    $(this.list).each(function(){
                        prostr += '<label><input type="checkbox" name="ch_sale_'+pro_id+'" value="'+this.name+'" />'+this.name+'</label>';
                    });

                    prostr += '</div>';
                } else {//单选
                    prostr += '<div>';
                    prostr += '<select id="pro_'+this.id+'">';

                    $(this.list).each(function(){
                        prostr += '<option value ="value_'+this.id+'">'+this.name+'</option>';
                    });

                    prostr += '</select>';
                    prostr += '</div>';
                }

                prostr += '</td>';
                prostr += '</tr>';
            });


            $("#second").after(prostr);
        }
    </script>

</head>
<body style="height: 100%; overflow-x: hidden; overflow-y: auto;">

<form id="form1" name="form1" onsubmit="return false">
    <input type="hidden" name="categoryId" value="<%=categoryId%>"/>
    <table style="width: 800px; margin: 2px;" class="bodytable1">
        <tr>
            <td colspan="6" class="table_title1">基本信息</td>
        </tr>
        <tr>
            <td>
                <div style="text-align: right; float: right">商品名称：</div>
            </td>
            <td colspan="2">
                <input type="text" id="product_name" name="product_name" validate="{required:true}" />
            </td>
            <td colspan="3"></td>
        </tr>
        <tr>
            <td>
                <div style="text-align: right; float: right">商品描述：</div>
            </td>
            <td colspan="2">
                <input type="text" id="product_des" name="product_des" validate="{required:true}" />
            </td>
            <td colspan="3"></td>
        </tr>

        <tr id="first">
            <td class="table_title1" colspan="6">商品属性</td>
        </tr>

        <tr>
            <td class="table_title1" colspan="6">商品信息</td>
        </tr>
        <tr>
            <td>
                <div style="text-align: right; float: right">京东价：</div>
            </td>
            <td>
                <input id="T_hobby" name="T_hobby" type="text" ltype="text" ligerui="{width:100}"/>
            </td>

            <td>
                <div style="text-align: right; float: right">市场价：</div>
            </td>
            <td>
                <input id="T_hobby" name="T_hobby" type="text" ltype="text" ligerui="{width:100}"/>
            </td>

            <td>
                <div style="text-align: right; float: right">货号：</div>
            </td>
            <td>
                <input id="T_hobby" name="T_hobby" type="text" ltype="text" ligerui="{width:100}"/>
            </td>
        </tr>
        <tr>
            <td>
                <div style="text-align: right; float: right">毛重：</div>
            </td>
            <td>
                <input id="T_hobby" name="T_hobby" type="text" ltype="text" ligerui="{width:100}"/>
            </td>

            <td>
                <div style="text-align: right; float: right">包装(长)：</div>
            </td>
            <td>
                <input id="T_hobby" name="T_hobby" type="text" ltype="text" ligerui="{width:100}"/>
            </td>

            <td>
                <div style="text-align: right; float: right">包装(宽)：</div>
            </td>
            <td>
                <input id="T_hobby" name="T_hobby" type="text" ltype="text" ligerui="{width:100}"/>
            </td>
        </tr>
        <tr>
            <td>
                <div style="text-align: right; float: right">产地：</div>
            </td>
            <td>
                <input id="T_hobby" name="T_hobby" type="text" ltype="text" ligerui="{width:100}"/>
            </td>

            <td>
                <div style="text-align: right; float: right">折扣：</div>
            </td>
            <td>
                <input id="T_hobby" name="T_hobby" type="text" ltype="text" ligerui="{width:100}"/>
            </td>
        </tr>

        <tr id="second">
            <td class="table_title1" colspan="6">销售属性</td>
        </tr>

        <tr>
            <td>
                &nbsp;
            </td>
            <td class="table_title1" colspan="5">
                <div id="maingrid"></div>
            </td>
        </tr>
        <tr>
            <td class="table_title1" colspan="6">商品图片</td>
        </tr>
        <tr>
            <td colspan="5">
                <div id="imgDiv">
                    <img id="img_1" src="resources/images/picture.jpg" alt="Logo" style="width:80px;height:80px;">
                    <img id="img_2" src="resources/images/picture.jpg" alt="Logo" style="width:80px;height:80px;">
                    <img id="img_3" src="resources/images/picture.jpg" alt="Logo" style="width:80px;height:80px;">
                    <img id="img_4" src="resources/images/picture.jpg" alt="Logo" style="width:80px;height:80px;">
                    <img id="img_5" src="resources/images/picture.jpg" alt="Logo" style="width:80px;height:80px;">
                    <img id="img_6" src="resources/images/picture.jpg" alt="Logo" style="width:80px;height:80px;">
                </div>
            </td>
            <td>
                <input type="button" value="上传图片" id="uploadBtn" name="uploadBtn" onclick="startLoad()"/>
            </td>
        </tr>
        <tr>
            <td class="table_title1" colspan="6">颜色图片</td>
        </tr>
        <tr>
            <td class="table_title1" colspan="6">物流信息</td>
        </tr>
        <tr>
            <td>
                <div style="text-align: right; float: right">发货地：</div>
            </td>
            <td>
                <input id="address_province" name="address_province" type="text" ltype="text" ligerui="{width:100}"/>
            </td>
            <td colspan="4">
                <input id="address_city" name="address_city" type="text" ltype="text" ligerui="{width:100}"/>
            </td>
        </tr>
        <tr>
            <td>
                <div style="text-align: right; float: right">运费：</div>
            </td>
            <td colspan="5">
                <input id="postage" name="postage" type="text" ltype="text" ligerui="{width:100}"/>
            </td>
        </tr>
        <tr>
            <td colspan="6">
                <div class="wareSortBtn">
                    <input id="releaseBtn" type="button" value="提交审核"/>
                </div>
            </td>
        </tr>
    </table>
</form>
</body>
</html>
