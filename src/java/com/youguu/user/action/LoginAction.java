package com.youguu.user.action;

import com.alibaba.fastjson.JSONObject;
import com.youguu.core.logging.Log;
import com.youguu.core.logging.LogFactory;
import com.youguu.core.util.ParamUtil;
import com.youguu.user.pojo.SysUser;
import com.youguu.user.service.ISysUserService;
import com.youguu.util.ResponseUtil;
import com.yyt.print.rpc.client.YytRpcClientFactory;
import com.yyt.print.rpc.client.product.IProductRpcService;
import com.yyt.print.rpc.client.user.IUserRpcService;
import com.yyt.print.user.response.AuthResponse;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.actions.DispatchAction;
import org.springframework.stereotype.Controller;

import javax.annotation.Resource;
import javax.servlet.ServletException;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@Controller("/loginAction")
public class LoginAction extends DispatchAction {

    @Resource
    private ISysUserService sysUserService;
    IUserRpcService userRpcService = YytRpcClientFactory.getUserRpcService();


    public ActionForward login(ActionMapping mapping, ActionForm form,
                               HttpServletRequest request, HttpServletResponse response) {
        response.setContentType("text/html");
        response.setCharacterEncoding("UTF-8");

        String username = ParamUtil.CheckParam(request.getParameter("username"), "");
        String password = ParamUtil.CheckParam(request.getParameter("password"), "");

        String ip = this.getIpAddr(request);

        AuthResponse authResponse = userRpcService.login(username, password, 5, ip);

        JSONObject result = new JSONObject();
        if(authResponse==null){
            result.put("success", false);
            result.put("message", "登录账户不正确");
        }

        if(authResponse.getStatus().equals("0000")){
            HttpSession session = request.getSession();
            // 用户登录session数据保存
            session.setAttribute("uid", authResponse.getUserId());
            session.setAttribute("uname", authResponse.getNickName());

            result.put("success", true);
            result.put("message", "登录成功");

            sysUserService.updateLoginTime(username);
        } else {
            result.put("success", false);
            result.put("message", authResponse.getMessage());
        }


        ResponseUtil.println(response, result);

        return null;
    }

    public ActionForward logout(ActionMapping mapping, ActionForm form,
                               HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("text/html");
        response.setCharacterEncoding("UTF-8");

        request.getSession().removeAttribute("uid");
        request.getSession().removeAttribute("uname");

        Cookie[] cookies = request.getCookies();
        if (cookies != null && cookies.length > 0) {
            for (Cookie cookie : cookies) {
                // 设置生存期为0
                cookie.setMaxAge(-1);
                cookie.setPath("/");
                // 设回Response中生效
                response.addCookie(cookie);
            }
        }
        request.getRequestDispatcher("/login.jsp").forward(request, response);

        return null;
    }

    private String getIpAddr(HttpServletRequest request) {
        String ip = request.getHeader("x-forwarded-for");
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("Proxy-Client-IP");
        }
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("WL-Proxy-Client-IP");
        }
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getRemoteAddr();
        }
        return ip;
    }
}
