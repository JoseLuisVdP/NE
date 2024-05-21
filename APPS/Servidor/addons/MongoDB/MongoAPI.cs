using Godot;
using Godot.Collections;
using System;
using System.Collections.Generic;
using MongoDB.Bson;
using MongoDB.Driver;
using MongoDB.Driver.Core;

public partial class MongoAPI : Node
{
	[Export]
	private String host = "mongodb://localhost:27017/?directConnection=true";
	private String addonPath = "res://addons/MongoDB/";
	public _MongoClient Connect(String hostIp){
		return this.Connect(hostIp, true);
	}
	public _MongoClient Connect(String hostIp, bool checkSslCertificate)
	{
		host = hostIp;
		var MongoClientScene = (PackedScene) ResourceLoader.Load(addonPath+"MongoClient/MongoClient.tscn");
		var ClientScene = MongoClientScene.Instantiate() as _MongoClient;
		AddChild(ClientScene);
		ClientScene.LoadClient(new MongoClient(host), addonPath, checkSslCertificate);
		ClientScene.Name = host;
		return ClientScene;
	}

}
