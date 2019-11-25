<template>
  <div id="app">
    <Layout />
  </div>
</template>

<script>
import Layout from './views/Layout.vue'

export default {
  name: 'app',
  components: {
    Layout
  }
}
</script>

<style>
#app {
  color: #2c3e50;
  height: 100%;
}
</style>
