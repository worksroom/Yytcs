package com.youguu.shop.vo;

import com.yyt.print.product.pojo.ShopUser;

/**
 * Created by leo on 2017/3/1.
 */
public class ShopUserVO extends ShopUser {
    private String userName;
    private String nickName;

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getNickName() {
        return nickName;
    }

    public void setNickName(String nickName) {
        this.nickName = nickName;
    }
}
