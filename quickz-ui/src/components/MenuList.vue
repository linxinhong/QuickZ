<template>
  <a-directory-tree multiple defaultExpandAll @select="onSelect" @expand="onExpand">
    <a-tree-node title="parent 0" key="0-0">
      <a-tree-node title="leaf 0-0" key="0-0-0" isLeaf />
      <a-tree-node title="leaf 0-1" key="0-0-1" isLeaf />
    </a-tree-node>
    <a-tree-node title="parent 1" key="0-1">
      <a-tree-node title="leaf 1-0" key="0-1-0" isLeaf />
      <a-tree-node title="leaf 1-1" key="0-1-1" isLeaf />
    </a-tree-node>
  </a-directory-tree>
</template>
<script>
  export default {
    methods: {
      onSelect(keys) {
        window.console.log('Trigger Select', keys);
      },
      onExpand() {
        window.console.log('Trigger Expand');
      },
    },
  };
</script>
