package com.youguu.product.action;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.youguu.core.util.ParamUtil;
import com.youguu.product.vo.CategoryComboBoxVO;
import com.youguu.product.vo.ProComboBoxVO;
import com.youguu.product.vo.ProValueVO;
import com.youguu.util.ResponseUtil;
import com.yyt.print.product.pojo.*;
import com.yyt.print.rpc.client.YytRpcClientFactory;
import com.yyt.print.rpc.client.product.IProductRpcService;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.actions.DispatchAction;
import org.springframework.stereotype.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.*;

/**
 * Created by leo on 2017/2/21.
 */
@Controller("/manager/product")
public class ProductAction extends DispatchAction {

    IProductRpcService productRpcService = YytRpcClientFactory.getProductRpcService();

    /**
     * 加载商品类别
     * @param mapping
     * @param form
     * @param request
     * @param response
     * @return
     */
    public ActionForward categoryComboBox(ActionMapping mapping,
                                          ActionForm form, HttpServletRequest request,
                                          HttpServletResponse response) {
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        int id = ParamUtil.CheckParam(request.getParameter("id"), -1);

        JSONObject jsonObject = new JSONObject();
        List<MallProductCategory> list = productRpcService.findMallProductCategoryList(id);
        if(list!=null && list.size()>0){
            List<CategoryComboBoxVO> comboBoxList = new ArrayList<>();
            for(MallProductCategory category : list){
                comboBoxList.add(new CategoryComboBoxVO(category.getId(), category.getName()));
            }
            jsonObject.put("status", "0000");
            jsonObject.put("message", "ok");
            jsonObject.put("result", comboBoxList);
        } else {
            jsonObject.put("status", "0001");
            jsonObject.put("message", "无数据");
            jsonObject.put("result", new ArrayList<>());

        }

        ResponseUtil.println(response, jsonObject);

        return null;
    }

    /**
     * 加载属性列表
     * @param mapping
     * @param form
     * @param request
     * @param response
     * @return
     */
    public ActionForward loadProList(ActionMapping mapping,
                                     ActionForm form, HttpServletRequest request,
                                     HttpServletResponse response) {
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        int classId = ParamUtil.CheckParam(request.getParameter("classId"), 0);

        List<MallProductCategoryPro> list = productRpcService.findProByClassId(classId);

        JSONObject jsonObject = new JSONObject();
        if(list!=null && list.size()>0){
            List<ProComboBoxVO> boxVOList = new ArrayList<>();
            for(MallProductCategoryPro categoryPro : list){
                ProComboBoxVO vo = new ProComboBoxVO();
                vo.setId(categoryPro.getId());
                vo.setName(categoryPro.getName());
                vo.setIsMultiple(categoryPro.getIsMultiple());
                vo.setIsNeed(categoryPro.getIsNeed());
                vo.setIsSku(categoryPro.getIsSku());

                List<MallProductCategoryProValue> valueList = productRpcService.findProValueByProId(categoryPro.getId());
                if(valueList!=null && !valueList.isEmpty()){
                    List<ProValueVO> valueVOList = new ArrayList<>();
                    for(MallProductCategoryProValue proValue : valueList){
                        ProValueVO valueVO = new ProValueVO();
                        valueVO.setId(proValue.getId());
                        valueVO.setName(proValue.getName());
                        valueVOList.add(valueVO);
                    }
                    vo.setList(valueVOList);
                }
                boxVOList.add(vo);
            }
            jsonObject.put("status", "0000");
            jsonObject.put("message", "ok");
            jsonObject.put("result", boxVOList);
        } else {
            jsonObject.put("status", "0001");
            jsonObject.put("message", "无数据");
            jsonObject.put("result", new ArrayList<>());
        }


        ResponseUtil.println(response, jsonObject);
        return null;
    }


}
