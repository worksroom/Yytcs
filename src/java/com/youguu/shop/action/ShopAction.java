package com.youguu.shop.action;

import com.alibaba.fastjson.JSONObject;
import com.youguu.core.util.ParamUtil;
import com.youguu.shop.vo.ShopUserVO;
import com.youguu.util.LigerUiToGrid;
import com.youguu.util.ResponseUtil;
import com.yyt.print.product.pojo.FareMould;
import com.yyt.print.product.pojo.ShopUser;
import com.yyt.print.rpc.client.YytRpcClientFactory;
import com.yyt.print.rpc.client.product.IProductRpcService;
import com.yyt.print.rpc.client.user.IUserRpcService;
import com.yyt.print.user.pojo.User;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.actions.DispatchAction;
import org.springframework.stereotype.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;

/**
 * Created by leo on 2017/3/1.
 */
@Controller("/manager/shop")
public class ShopAction extends DispatchAction {

    IUserRpcService userRpcService = YytRpcClientFactory.getUserRpcService();
    IProductRpcService productRpcService = YytRpcClientFactory.getProductRpcService();

    /**
     * 查询所有店员
     * @param mapping
     * @param form
     * @param request
     * @param response
     * @return
     */
    public ActionForward findShopUids(ActionMapping mapping,
                                       ActionForm form, HttpServletRequest request,
                                       HttpServletResponse response) {
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        int shopId = (int)request.getSession().getAttribute("shopId");

        List<ShopUser> list = productRpcService.findShopUids(shopId);

        List<Integer> userIdList = new ArrayList<>();
        if(list!=null && list.size()>0){
            for(ShopUser shopUser : list){
                userIdList.add(shopUser.getUserId());
            }
        }
        Map<Integer, User> userMap = userRpcService.getUserMap(userIdList);

        List<ShopUserVO> voList = new ArrayList<>();
        if(list!=null && list.size()>0){
            for(ShopUser shopUser : list){
                ShopUserVO shopUserVO = new ShopUserVO();
                shopUserVO.setId(shopUser.getId());
                shopUserVO.setUserId(shopUser.getUserId());

                if(userMap!=null && userMap.size()>0){
                    User user = userMap.get(shopUser.getUserId());
                    shopUserVO.setNickName(user.getNickName());
                    shopUserVO.setUserName(user.getUserName());
                }

                shopUserVO.setType(shopUser.getType());
                shopUserVO.setCreateTime(shopUser.getCreateTime());
                voList.add(shopUserVO);
            }
        }

        String gridJson = LigerUiToGrid.toGridJSON(voList, new String[]{"id", "shopId", "userId", "nickName", "type", "createTime"}, null);

        ResponseUtil.println(response, gridJson);
        return null;
    }

    /**
     * 添加店员
     * @param mapping
     * @param form
     * @param request
     * @param response
     * @return
     */
    public ActionForward addShopUser(ActionMapping mapping,
                                       ActionForm form, HttpServletRequest request,
                                       HttpServletResponse response) {
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        int type = ParamUtil.CheckParam(request.getParameter("type"), 0);
        int userId = ParamUtil.CheckParam(request.getParameter("userId"), 0);

        ShopUser shopUser = new ShopUser();
        int shopId = (int)request.getSession().getAttribute("shopId");
        shopUser.setShopId(shopId);
        shopUser.setType(type);
        shopUser.setUserId(userId);
        shopUser.setCreateTime(new Date());

        int dbFlag = productRpcService.addShopUser(shopUser);
        JSONObject result = new JSONObject();
        if(dbFlag>0){
            result.put("success", true);
            result.put("message", "添加成功");
        } else{
            result.put("success", false);
            result.put("message", "添加失败");
        }
        ResponseUtil.println(response, result);
        return null;
    }
}
