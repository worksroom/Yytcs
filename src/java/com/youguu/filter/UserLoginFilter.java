package com.youguu.filter;

import com.youguu.core.util.ParamUtil;

import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

public class UserLoginFilter implements Filter {
	private FilterConfig config;

	@Override
	public void doFilter(ServletRequest req, ServletResponse rep,
			FilterChain chain) throws IOException, ServletException {

		String indexPath = ((HttpServletRequest) req).getContextPath()
				+ ParamUtil.CheckParam(config.getInitParameter("indexPath"), "/index.jsp");

		HttpServletRequest request = (HttpServletRequest) req;
		HttpServletResponse response = (HttpServletResponse) rep;

		String url = request.getRequestURI();
		boolean isFilter = true;

		// 如果不是jsp、do、html，不过滤
		if (!url.endsWith(".jsp") && !url.endsWith(".do") && !url.endsWith(".html") && !url.endsWith("/") && !url.endsWith(".shtml")) {
			isFilter = false;
		}
		HttpSession session = request.getSession();
		if (isFilter) {// 获取url 如果为login相关的路径
			String uid = (String) session.getAttribute("uid");
			if (uid == null) { // 未登录
				response.sendRedirect(indexPath);
			} else {
				chain.doFilter(request, response);
			}
		} else {
			chain.doFilter(request, response);
		}

	}

	@Override
	public void init(FilterConfig arg0) throws ServletException {
		this.config = arg0;
	}

	@Override
	public void destroy() {

	}

}
