package com.youguu.product.vo;

/**
 * Created by leo on 2017/2/21.
 */
public class CategoryComboBoxVO {
    /**
     * 类别ID
     */
    private int id;

    /**
     * 类别名称
     */
    private String name;

    public CategoryComboBoxVO(int id, String name) {
        this.id = id;
        this.name = name;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }
}
