<template>
  <a-layout id="layout-main">
    <a-layout-header :style="{padding: '0 20px'}">
      <span class="title"><img src="../assets/favicon.png" :style="{height: '1.2em', margin: '5px 5px 8px'}">QuickZ</span>
    </a-layout-header>
    <a-layout>
      <a-layout-sider width="200" style="background: #fff">
        <a-menu
          mode="inline"
          :defaultSelectedKeys="['1']"
          :defaultOpenKeys="['sub1']"
          :style="{ height: '100%', borderRight: 0 }"
        >
            <a-menu-item key="1"><a-icon type="profile" />智能菜单</a-menu-item>
            <a-menu-item key="2"><a-icon type="down-square" />Vim热键</a-menu-item>
            <a-menu-item key="3"><a-icon type="thunderbolt" />变量</a-menu-item>
            <a-menu-item key="4"><a-icon type="tags" />标签</a-menu-item>
            <a-menu-item key="5"><a-icon type="setting" />全局设置</a-menu-item>
        </a-menu>
      </a-layout-sider>
      <a-layout style="padding: 0px 20px 0px">
        <a-layout-content
          :style="{ background: '#fff', padding: '24px', Height: '100%;' }"
        >
          <MenuList />
        </a-layout-content>
      </a-layout>
    </a-layout>
  </a-layout>
</template>
<script>
import MenuList from '../components/MenuList'
  export default {
    data() {
      return {
        collapsed: false,
      };
    },
    components: {
        MenuList
    }
  };
</script>

<style>
  #layout-main {
      height: 100%;
  }

  .title {
      color: aliceblue;
      font-size: 1.5em;
  }

  #layout-main .logo {
    width: 120px;
    height: 31px;
    background: rgba(255, 255, 255, 0.2);
    margin: 16px 28px 16px 0;
    padding: 0px;
    float: left;
  }
</style>
