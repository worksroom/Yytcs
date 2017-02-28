<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String path = request.getContextPath();
    String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + path + "/";
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <base href="<%=basePath%>">
    <title>添加仓库位置</title>
    <meta content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" name="viewport">
    <script type="text/javascript" src="https://code.jquery.com/jquery-1.12.4.min.js"></script>

    <link href="resources/ligerUI/skins/Aqua/css/ligerui-all.css" rel="stylesheet" type="text/css">
    <link href="resources/ligerUI/skins/Gray/css/all.css" rel="stylesheet" type="text/css">
    <script src="resources/ligerUI/js/core/base.js" type="text/javascript"></script>
    <script src="resources/ligerUI/js/ligerui.all.js" type="text/javascript"></script>
    <script src="resources/js/city.js" type="text/javascript"></script>


    <script type="text/javascript">
        var groupicon = "resources/ligerUI/skins/icons/communication.gif";
        var form;
        var dialog = frameElement.dialog;

        $(function () {
            form = $("#form2").ligerForm({
                inputWidth: 170, labelWidth: 90, space: 10,
                fields: [
                    {
                        display: "省份",
                        name: "fCode",
                        newline: false,
                        type: "select",
                        comboboxName: "fCodeCombo",
                        options: {
                            textField: "name",
                            valueField: "id",
                            data: getProvinceData(),
                            onSelected: f_onProvinceChanged
                        }
                    },
                    {
                        display: "省份名称",
                        name: "fName",
                        newline: false,
                        type: "hidden"
                    },
                    {
                        display: "城市",
                        name: "sCode",
                        newline: false,
                        type: "select",
                        comboboxName: "sCodeCombo",
                        options: {
                            textField: "name",
                            valueField: "id",
                            onSelected: f_onCityChanged
                        }
                    },
                    {
                        display: "城市名称",
                        name: "sName",
                        newline: false,
                        type: "hidden"
                    }
                ]
            });
        });


        /**
        * 获取一级省份(直辖市)
        * @returns {Array}
         */
        function getProvinceData() {
            var data = [];
            var provinceData = city[0].addressList;
            $(provinceData).each(function () {
                if (!this.id) return;
                if (!exist(this.id, data)) {
                    data.push({
                        id: this.id,
                        name: this.name
                    });
                }
            });
            return data;
            function exist(id, data) {
                for (var i = 0, l = data.length; i < l; i++) {
                    if (data[i].id.toString().trim() == id.toString().trim()) {
                        return true;
                    }
                }
                return false;
            }
        }

        /**
        * 获取城市,根据省份ID查询
        * @param provinceId 省份(直辖市)ID
        * @returns {Array}
         */
        function getCityData(provinceId) {
            var data = [];
            var provinceData = city[0].addressList;
            var index = 1;
            $(provinceData).each(function () {
                if (this.id.toString().trim() == provinceId.toString().trim()){
                    return false;
                }
                index ++;
            });

            if(index>(city.length-1)){
                return data;
            }
            var cityData = city[index].addressList;

            $(cityData).each(function () {
                if (!this.id) return;
                if (!exist(this.id, data)) {
                    data.push({
                        id: this.id,
                        name: this.name
                    });
                }
            });
            return data;

            function exist(id, data) {
                for (var i = 0, l = data.length; i < l; i++) {
                    if (data[i].id.toString().trim() == id.toString().trim()) return true;
                }
                return false;
            }
        }


        /**
        * 一级省份 改变事件：清空城市,重新绑定数据
        * @param provinceId 省份ID
         */
        function f_onProvinceChanged(provinceId, name) {
            form.setData({"fName": name});
            var combo = liger.get('sCodeCombo');
            if (!combo) return;
            var data = getCityData(provinceId);
            combo.clear();
            combo.set('data', data);
        }

        /**
        * 城市(地区)选中事件，设置隐藏属性
        * @param cityId
        * @param name
         */
        function f_onCityChanged(cityId, name){
            form.setData({"sName": name});
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
