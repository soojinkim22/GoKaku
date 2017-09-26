
var Index = new Vue({
  el: "#app",
  data: {
   title: "GoKaku Login",
   username : "soojin",
   password : ""
  },
  methods : {
  	login : function() {
  	  alert('Login Name is ' + this.username + this.password);
  	  
  	  axios.post('/api/auth', {
        username: this.username,
        password: this.password
      })
      .then(function (response) {
        console.log(response.data);
        if (response.data == 'success') {
          location.href= '/home';
        }
      })
      .catch(function (error) {
        console.log(error);
      });
  	}
  }
});


/*axios.get('/api/users',query);
axios.get('/api/users/:id',{});
axios.post('/api/users',param);
axios.put('/api/users/:id',param);
axios.delete('/api/users/:id',param);

axios.get('/api/buses',query);
axios.get('/api/buses/:id',{});
axios.post('/api/buses',param);
axios.put('/api/buses/:id',param);
axios.delete('/api/buses/:id',param);
*/