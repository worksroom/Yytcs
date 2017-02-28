package com.youguu.product.action;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.youguu.core.util.PageHolder;
import com.youguu.core.util.ParamUtil;
import com.youguu.util.LigerUiToGrid;
import com.youguu.util.ResponseUtil;
import com.yyt.print.product.pojo.*;
import com.yyt.print.product.query.MallGoodsQuery;
import com.yyt.print.rpc.client.YytRpcClientFactory;
import com.yyt.print.rpc.client.product.IProductRpcService;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.actions.DispatchAction;
import org.springframework.stereotype.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.UnsupportedEncodingException;
import java.util.*;

/**
 * Created by leo on 2017/2/14.
 */
@Controller("/manager/goods")
public class MallGoodsAction extends DispatchAction {

    IProductRpcService productRpcService = YytRpcClientFactory.getProductRpcService();

    /**
     * 货品列表查询
     * @param mapping
     * @param form
     * @param request
     * @param response
     * @return
     */
    public ActionForward mallGoodsList(ActionMapping mapping,
                                 ActionForm form, HttpServletRequest request,
                                 HttpServletResponse response) {
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        int page = ParamUtil.CheckParam(request.getParameter("page"), 1);
        int pagesize = ParamUtil.CheckParam(request.getParameter("pagesize"), 20);

        int classId = ParamUtil.CheckParam(request.getParameter("classId"), -1);
        String name = ParamUtil.CheckParam(request.getParameter("name"), "");
        int shopId = ParamUtil.CheckParam(request.getParameter("shopId"), -1);
        int status = ParamUtil.CheckParam(request.getParameter("status"), -1);
        String shopName = ParamUtil.CheckParam(request.getParameter("shopName"), "");

        MallGoodsQuery query = new MallGoodsQuery();
        query.setClassId(classId);
        if(name!=null && !"".equals(name)){
            query.setName(name);
        }

        query.setPageIndex(page);
        query.setPageSize(pagesize);
        query.setShopId(shopId);
        if(shopName!=null && !"".equals(shopName)){
            query.setShopName(shopName);
        }

        query.setStatus(status);

        PageHolder<MallGoods> pageHolder = productRpcService.findMallGoods(query);

        String gridJson = LigerUiToGrid.toGridJSON(pageHolder, new String[]{"id", "name", "des", "classId", "status", "img", "createTime", "updateTime"}, null);

        ResponseUtil.println(response, gridJson);
        return null;
    }


    /**
     * 新增货品
     * @param mapping
     * @param form
     * @param request
     * @param response
     * @return
     */
    public ActionForward saveGoods(ActionMapping mapping,
                                   ActionForm form, HttpServletRequest request,
                                   HttpServletResponse response) throws UnsupportedEncodingException {
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        JSONObject result = new JSONObject();

        String pn = ParamUtil.CheckParam(request.getParameter("product_name"), ""); //商品名称
        String product_name = java.net.URLDecoder.decode((String)request.getParameter("product_name"),"UTF-8");
        String product_des = ParamUtil.CheckParam(request.getParameter("product_des"), "");//商品描述
        int categoryId = ParamUtil.CheckParam(request.getParameter("categoryId"), 0);//商品类别ID

        String sku_list = ParamUtil.CheckParam(request.getParameter("sku_list"), ""); //SKU组合
        String img_list = ParamUtil.CheckParam(request.getParameter("img_list"), ""); //商品图片

        /**
         * 遍历商品类别下所有属性，获取属性值，结构存Map
         */
        List<MallProductCategoryPro> list = productRpcService.findProByClassId(categoryId);
        Map<String, String> proValueMap = new HashMap<>();
        if(list!=null && !list.isEmpty()){
            for(MallProductCategoryPro categoryPro : list){
                if(categoryPro.getIsSku()==0){
                    String pro_value = ParamUtil.CheckParam(request.getParameter("pro_"+categoryPro.getId()), "");
                    proValueMap.put(String.valueOf(categoryPro.getId()), pro_value);
                }

            }
        }


        int address_id = ParamUtil.CheckParam(request.getParameter("address_id"), 0);//仓库ID
        int fare_id = ParamUtil.CheckParam(request.getParameter("fare_id"), 0);//运费模板ID

        /**
         * 参数封装初始化
         */
        MallGoodsSet mallGoodsSet = new MallGoodsSet();
        MallGoods mallGoods = new MallGoods();
        List<MallGoodBasePro> baseProList = new ArrayList<>();
        List<MallProductSet> productSetList = new ArrayList<>();
        List<MallProductExt> productExtList = new ArrayList<>();

        /**
         * 设置货品基本信息
         */
        mallGoods.setName(product_name);
        int userId = (int)request.getSession().getAttribute("uid");
        ShopUser shopUser = productRpcService.getShopIdFromUid(userId);
        mallGoods.setShopId(shopUser.getShopId());
        mallGoods.setDes(product_des);
        mallGoods.setClassId(categoryId);
        mallGoods.setStatus(0);//0:待审
        mallGoods.setImg(img_list);
        mallGoods.setCreateTime(new Date());

        mallGoodsSet.setMallGoods(mallGoods);

        /**
         * 设置商品基本属性值
         */
        Iterator<Map.Entry<String, String>> it = proValueMap.entrySet().iterator();
        while (it.hasNext()) {
            Map.Entry<String, String> entry = it.next();
            MallGoodBasePro basePro = new MallGoodBasePro();
            basePro.setClassProId(Integer.parseInt(entry.getKey()));
            basePro.setClassProValue(entry.getValue());
            basePro.setCreateTime(new Date());
            baseProList.add(basePro);
        }
        mallGoodsSet.setBpro(baseProList);

        /**
         * 设置SKU信息
         */
        JSONArray skuArray = JSONArray.parseArray(sku_list);
        if(skuArray!=null && skuArray.size()>0){
            for(int i = 0 ; i < skuArray.size(); i++){
                MallProductSet mallProductSet = new MallProductSet();
                List<MallProductSalePro> saleProList = new ArrayList<>();

                JSONObject sku = (JSONObject)skuArray.get(i);

                String key = sku.getString("key");//属性值
                String sku_price = sku.getString("sku_price");//价格
                String sku_inventory = sku.getString("sku_inventory");//库存
                String sku_discount_price = sku.getString("sku_discount_price");//折扣价

                MallProduct mallProduct = new MallProduct();
                mallProduct.setSellUserId(userId);
                mallProduct.setName(product_name);
                mallProduct.setPic("");//是否需要此字段？应该加一个SKU编码字段？
                mallProduct.setPrice(Double.parseDouble(sku_price));
                mallProduct.setSalePrice(Double.parseDouble(sku_discount_price));
                mallProduct.setStoreNum(Integer.parseInt(sku_inventory));
                mallProduct.setCreateTime(new Date());

                /**
                 * 设置销售属性
                 */
                List<String> keyList = JSONArray.parseArray(key, String.class);
                for(String kk : keyList){
                    int proId = Integer.parseInt(kk.split("_")[1]);
                    int proValueId = Integer.parseInt(kk.split("_")[2]);
                    MallProductSalePro salePro = new MallProductSalePro();
                    salePro.setClassProId(proId);
                    salePro.setClassProValueId(proValueId);
                    salePro.setCreateTime(new Date());
                    saleProList.add(salePro);
                }

                mallProductSet.setMallProduct(mallProduct);
                mallProductSet.setSalePro(saleProList);
                productSetList.add(mallProductSet);
            }
            mallGoodsSet.setList(productSetList);
        } else {
            result.put("status", "0001");
            result.put("message", "还没有填写SKU信息，无法提交");
            ResponseUtil.println(response, result);
            return null;
        }

        /**
         * 设置商品扩展信息(如仓库位置，运费信息等)
         * type:
         * 1 库存位置
         * 2 运费模板
         */
        MallProductExt ext1 = new MallProductExt();
        ext1.setType(1);
        ext1.setThridId(address_id);
        ext1.setCreateTime(new Date());
        productExtList.add(ext1);

        MallProductExt ext2 = new MallProductExt();
        ext2.setType(2);
        ext2.setThridId(fare_id);
        ext2.setCreateTime(new Date());
        productExtList.add(ext2);

        mallGoodsSet.setExts(productExtList);

        int dbFlag = productRpcService.shelves(mallGoodsSet);

        if(dbFlag>0){
            result.put("status", "0000");
            result.put("message", "提交成功");
        } else {
            result.put("status", "0001");
            result.put("message", "提交失败");
        }

        ResponseUtil.println(response, result);
        return null;
    }


    /**
     * 修改货品
     * @param mapping
     * @param form
     * @param request
     * @param response
     * @return
     */
    public ActionForward updateGoods(ActionMapping mapping,
                                     ActionForm form, HttpServletRequest request,
                                     HttpServletResponse response) throws UnsupportedEncodingException {
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        JSONObject result = new JSONObject();

        int goodsId = ParamUtil.CheckParam(request.getParameter("goodsId"), 0);//商品类别ID
        String product_name = java.net.URLDecoder.decode((String)request.getParameter("product_name"),"UTF-8");
        String product_des = ParamUtil.CheckParam(request.getParameter("product_des"), "");//商品描述
        int categoryId = ParamUtil.CheckParam(request.getParameter("categoryId"), 0);//商品类别ID

        String sku_list = ParamUtil.CheckParam(request.getParameter("sku_list"), ""); //SKU组合
        String img_list = ParamUtil.CheckParam(request.getParameter("img_list"), ""); //商品图片

        /**
         * 遍历商品类别下所有属性，获取属性值，结构存Map
         */
        List<MallProductCategoryPro> list = productRpcService.findProByClassId(categoryId);
        Map<String, String> proValueMap = new HashMap<>();
        if(list!=null && !list.isEmpty()){
            for(MallProductCategoryPro categoryPro : list){
                if(categoryPro.getIsSku()==0){
                    String pro_value = ParamUtil.CheckParam(request.getParameter("pro_"+categoryPro.getId()), "");
                    proValueMap.put(String.valueOf(categoryPro.getId()), pro_value);
                }

            }
        }


        int address_id = ParamUtil.CheckParam(request.getParameter("address_id"), 0);//仓库ID
        int fare_id = ParamUtil.CheckParam(request.getParameter("fare_id"), 0);//运费模板ID

        /**
         * 参数封装初始化
         */
        MallGoodsSet mallGoodsSet = new MallGoodsSet();
        MallGoods mallGoods = new MallGoods();
        List<MallGoodBasePro> baseProList = new ArrayList<>();
        List<MallProductSet> productSetList = new ArrayList<>();
        List<MallProductExt> productExtList = new ArrayList<>();

        /**
         * 设置货品基本信息
         */
        mallGoods.setId(goodsId);
        mallGoods.setName(product_name);
        int userId = (int)request.getSession().getAttribute("uid");
        ShopUser shopUser = productRpcService.getShopIdFromUid(userId);
        mallGoods.setShopId(shopUser.getShopId());
        mallGoods.setDes(product_des);
        mallGoods.setClassId(categoryId);
        mallGoods.setStatus(0);//0:待审
        mallGoods.setImg(img_list);
        mallGoods.setCreateTime(new Date());

        mallGoodsSet.setMallGoods(mallGoods);

        /**
         * 设置商品基本属性值
         */
        Iterator<Map.Entry<String, String>> it = proValueMap.entrySet().iterator();
        while (it.hasNext()) {
            Map.Entry<String, String> entry = it.next();
            MallGoodBasePro basePro = new MallGoodBasePro();
            basePro.setGoodsId(goodsId);
            basePro.setClassProId(Integer.parseInt(entry.getKey()));
            basePro.setClassProValue(entry.getValue());
            basePro.setCreateTime(new Date());
            baseProList.add(basePro);
        }
        mallGoodsSet.setBpro(baseProList);

        /**
         * 设置SKU信息
         */
        JSONArray skuArray = JSONArray.parseArray(sku_list);
        if(skuArray!=null && skuArray.size()>0){
            for(int i = 0 ; i < skuArray.size(); i++){
                MallProductSet mallProductSet = new MallProductSet();
                List<MallProductSalePro> saleProList = new ArrayList<>();

                JSONObject sku = (JSONObject)skuArray.get(i);

                String key = sku.getString("key");//属性值
                String sku_price = sku.getString("sku_price");//价格
                String sku_inventory = sku.getString("sku_inventory");//库存
                String sku_discount_price = sku.getString("sku_discount_price");//折扣价

                MallProduct mallProduct = new MallProduct();
                mallProduct.setGoodsId(goodsId);
                mallProduct.setSellUserId(userId);
                mallProduct.setName(product_name);
                mallProduct.setPic("");//是否需要此字段？应该加一个SKU编码字段？
                mallProduct.setPrice(Double.parseDouble(sku_price));
                mallProduct.setSalePrice(Double.parseDouble(sku_discount_price));
                mallProduct.setStoreNum(Integer.parseInt(sku_inventory));
                mallProduct.setCreateTime(new Date());

                /**
                 * 设置销售属性
                 */
                List<String> keyList = JSONArray.parseArray(key, String.class);
                for(String kk : keyList){
                    int proId = Integer.parseInt(kk.split("_")[1]);
                    int proValueId = Integer.parseInt(kk.split("_")[2]);
                    MallProductSalePro salePro = new MallProductSalePro();
                    salePro.setGoodsId(goodsId);
                    salePro.setClassProId(proId);
                    salePro.setClassProValueId(proValueId);
                    salePro.setCreateTime(new Date());
                    saleProList.add(salePro);
                }

                mallProductSet.setMallProduct(mallProduct);
                mallProductSet.setSalePro(saleProList);
                productSetList.add(mallProductSet);
            }
            mallGoodsSet.setList(productSetList);
        } else {
            result.put("status", "0001");
            result.put("message", "还没有填写SKU信息，无法提交");
            ResponseUtil.println(response, result);
            return null;
        }

        /**
         * 设置商品扩展信息(如仓库位置，运费信息等)
         * type:
         * 1 库存位置
         * 2 运费模板
         */
        MallProductExt ext1 = new MallProductExt();
        ext1.setGoodsId(goodsId);
        ext1.setType(1);
        ext1.setThridId(address_id);
        ext1.setCreateTime(new Date());
        productExtList.add(ext1);

        MallProductExt ext2 = new MallProductExt();
        ext2.setGoodsId(goodsId);
        ext2.setType(2);
        ext2.setThridId(fare_id);
        ext2.setCreateTime(new Date());
        productExtList.add(ext2);

        mallGoodsSet.setExts(productExtList);

        int dbFlag = productRpcService.goodAddProduct(mallGoodsSet);

        if(dbFlag>0){
            result.put("status", "0000");
            result.put("message", "修改成功");
        } else {
            result.put("status", "0001");
            result.put("message", "修改失败");
        }

        ResponseUtil.println(response, result);
        return null;
    }



    public ActionForward getGoods(ActionMapping mapping,
                                  ActionForm form, HttpServletRequest request,
                                  HttpServletResponse response) {
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        int goodsId = ParamUtil.CheckParam(request.getParameter("goodsId"), 0);//商品类别ID

        MallGoodsSet mallGoodsSet = productRpcService.getMallGoodsSetByGood(goodsId);
        String responseText = null;
        if(mallGoodsSet!=null){
            responseText = JSONObject.toJSONString(mallGoodsSet);
        } else {
            JSONObject result = new JSONObject();
            result.put("success", false);
            result.put("message", "未检索到该条数据");
            responseText = result.toJSONString();

        }
        ResponseUtil.println(response, responseText);
        return null;
    }

    /**
     * 更新单条SKU信息
     * @param mapping
     * @param form
     * @param request
     * @param response
     * @return
     */
    public ActionForward updateSku(ActionMapping mapping,
                                     ActionForm form, HttpServletRequest request,
                                     HttpServletResponse response) {
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        int id = ParamUtil.CheckParam(request.getParameter("id"), 0);
        String sku_price = ParamUtil.CheckParam(request.getParameter("sku_price"), "");
        String sku_discount_price = ParamUtil.CheckParam(request.getParameter("sku_discount_price"), "");
        String sku_inventory = ParamUtil.CheckParam(request.getParameter("sku_inventory"), "");

        MallProduct mallProduct = new MallProduct();
        mallProduct.setId(id);
        mallProduct.setPrice(Double.parseDouble(sku_price));
        mallProduct.setSalePrice(Double.parseDouble(sku_discount_price));
        mallProduct.setStoreNum(Integer.parseInt(sku_inventory));
        mallProduct.setCreateTime(new Date());

        int dbFlag = productRpcService.updateSku(mallProduct);

        JSONObject result = new JSONObject();
        if(dbFlag>0){
            result.put("status", "0000");
            result.put("message", "修改成功");
        } else {
            result.put("status", "0001");
            result.put("message", "修改失败");
        }

        ResponseUtil.println(response, result);
        return null;
    }
}
