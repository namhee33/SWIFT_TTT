myApp.controller('usersController', function(userFactory, $location, $routeParams){
	var _this = this;
	
	//all users
	this.users = {};
	//login user
	this.login_user = {};
	//find a specific user to show his list
	this.refer_user = {};

	userFactory.user_index(function(data){
		if(data.message){
			_this.errors = data.errors.name.message;
		}else{
			this.users = data;
		}
	});

	if($routeParams.name !== undefined){
		console.log('user_name to find: ', $routeParams.name);
		userFactory.get_user_by_name($routeParams.name, function(data){
			_this.refer_user = data;
		});
	}

	this.login = function(){
		console.log('new name@@@ ', this.new_name);
		userFactory.get_user_by_name(this.new_name, function(data){
			if(data == null || data.length <= 0){
				console.log('no user found. make new user registration');
				userFactory.registerUser({name:_this.new_name}, function(new_user){
					console.log("new user", new_user);
					_this.login_user = new_user;
					_this.new_name = '';	
					
					$location.path('/main');
				});
			}else{
				console.log('old user to login: ', data);
				_this.login_user = data;
				_this.new_name = '';
				
				$location.path('/main');
			}
		})
	}

	this.logout = function(){
		console.log('logout.....');
		_this.login_user = {};
	}
});