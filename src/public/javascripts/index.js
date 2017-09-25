
var Index = new Vue({
  el: "#app",
  data: {
   title: "hogehoge",      
   soojin: "kkk",
   hyungjun: "ccc"
  },
  mounted() {
    console.log("created");
  },
  methods: {
    test () {
      alert(this.soojin);
    },

    test2 () {
      alert(this.hyungjun);
    }
  }
});
