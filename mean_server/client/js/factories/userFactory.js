var myApp = angular.module('myApp', ['ngRoute', 'ngMessages']);

myApp.factory('userFactory', function($http){
	var users = [];
	var factory = {};

	factory.user_index = function(callback){
		$http.get('/user_index').success(function(output){
			callback(output);
		});
	}

	factory.get_user_by_name = function(name, callback){
		$http.get('/get_user_by_name/'+name).success(function(output){
			callback(output);
		});
	}

	factory.registerUser = function(new_user, callback){
		$http.post('/registerUser', new_user).success(function(output){
			callback(output);
		});
	}
	return factory;
});