using UnityEditor;
using UnityEngine;
using System.IO;
using System.Collections;
using System.Collections.Generic;
using System;

public class PerformBuild
{
	private static string BUILD_LOCATION = "+buildlocation";

	public static string GetBuildLocation(BuildTarget buildTarget)
	{
		string[] args = System.Environment.GetCommandLineArgs();
		int indexOfBuildLocation = System.Array.IndexOf(args, BUILD_LOCATION);
		if (indexOfBuildLocation >= 0)
  		{	
			indexOfBuildLocation++;
			Debug.Log(string.Format("Build Location for {0} set to {1}", buildTarget.ToString(), args[indexOfBuildLocation]));
			return args[indexOfBuildLocation];
 		}
		else 
		{
			Debug.Log(string.Format("Build Location for {0} not set. Defaulting to {1}",buildTarget.ToString(), 
			                        EditorUserBuildSettings.GetBuildLocation(buildTarget)));
			return EditorUserBuildSettings.GetBuildLocation(buildTarget);
		}
	}

	public static string[] GetBuildScenes()
	{
		List<string> names = new List<string>();
		
		foreach(EditorBuildSettingsScene e in EditorBuildSettings.scenes)
		{
			if(e==null)
				continue;
			
			if(e.enabled)
				names.Add(e.path);
		}
		return names.ToArray();
	}

	public static void BuildPlayerTarget(BuildTarget target){

		Debug.Log("Command line build " + target.ToString() + " version\n------------------\n------------------");


		string[] scenes = GetBuildScenes();
		string path = GetBuildLocation(target);
		if(scenes == null || scenes.Length==0 || path == null)
			return;

		Debug.Log(string.Format("Path: \"{0}\"", path));
		for(int i=0; i < scenes.Length; ++i)
		{
			Debug.Log(string.Format("Scene[{0}]: \"{1}\"", i, scenes[i]));
		}

		Debug.Log(string.Format("Creating Directory \"{0}\" if it does not exist", path));
		FileInfo fileInfo = new FileInfo (path);
		if (!fileInfo.Exists) {
			Debug.Log(string.Format("Not.Exists {0}", fileInfo.ToString()));
			if (!fileInfo.Directory.Exists) {
				Debug.Log(string.Format("Directory.Dont.Exists {0}", fileInfo.Directory.ToString()));
				fileInfo.Directory.Create ();
			} else {
				if (!fileInfo.Directory.Parent.Exists) {
					Debug.Log(string.Format("Directory.Parent.Exists {0}", fileInfo.Directory.Parent.ToString()));
					fileInfo.Directory.Parent.Create ();
				}
			}
		} else {
			Debug.Log(string.Format("Exists {0}", fileInfo.ToString()));
		}

		Debug.Log(string.Format("Switching Build Target to {0}", target.ToString()));
		BuildTargetGroup buildTargetGroup = BuildPipeline.GetBuildTargetGroup (target);

    // IL2CPP
    PlayerSettings.SetScriptingBackend(buildTargetGroup, ScriptingImplementation.IL2CPP);

		EditorUserBuildSettings.SwitchActiveBuildTarget(buildTargetGroup, target);

		Debug.Log("Starting " + target.ToString() + " Build!");
		BuildPipeline.BuildPlayer(scenes, path, target, BuildOptions.None);

	}
	
	[UnityEditor.MenuItem("Perform Build/iOS Command Line Build")]
	static void CommandLineBuildiOS ()
	{
		BuildPlayerTarget(BuildTarget.iOS);
	}
	
	[UnityEditor.MenuItem("Perform Build/Android Command Line Build")]
	public static void CommandLineBuildAndroid ()
	{
		BuildTarget target = BuildTarget.Android;

		string JavaHome = Environment.GetEnvironmentVariable("JAVA_HOME");
		string AndroidSdkRoot = Environment.GetEnvironmentVariable("ANDROID_SDK_ROOT");
		string AndroidNdkRoot = Environment.GetEnvironmentVariable("ANDROID_NDK_ROOT");
		Debug.Log("JAVA_HOME: " + JavaHome);
		Debug.Log("ANDROID_SDK_ROOT: " + AndroidSdkRoot);
		Debug.Log("ANDROID_NDK_ROOT: " + AndroidNdkRoot);

		Debug.Log("Command line build " + target.ToString() + " version\n------------------\n------------------");

		string[] scenes = GetBuildScenes();
		string path = GetBuildLocation(target);
		if(scenes == null || scenes.Length==0 || path == null)
			return;

		Debug.Log(string.Format("Path: \"{0}\"", path));
		for(int i=0; i < scenes.Length; ++i)
		{
			Debug.Log(string.Format("Scene[{0}]: \"{1}\"", i, scenes[i]));
		}

		Debug.Log(string.Format("Creating Directory \"{0}\" if it does not exist", path));
		FileInfo fileInfo = new FileInfo (path);
		if (!fileInfo.Exists) {
			Debug.Log(string.Format("Not.Exists {0}", fileInfo.ToString()));
			if (!fileInfo.Directory.Exists) {
				Debug.Log(string.Format("Directory.Dont.Exists {0}", fileInfo.Directory.ToString()));
				fileInfo.Directory.Create ();
			} else {
				if (!fileInfo.Directory.Parent.Exists) {
					Debug.Log(string.Format("Directory.Parent.Exists {0}", fileInfo.Directory.Parent.ToString()));
					fileInfo.Directory.Parent.Create ();
				}
			}
		} else {
			Debug.Log(string.Format("Exists {0}", fileInfo.ToString()));
		}

		EditorPrefs.SetString ("JdkPath", JavaHome);
		EditorPrefs.SetString ("AndroidSdkRoot", AndroidSdkRoot);
		EditorPrefs.SetString ("AndroidNdkRoot", AndroidNdkRoot);

		PlayerSettings.SetScriptingBackend(BuildTargetGroup.Android, ScriptingImplementation.IL2CPP);

		Debug.Log(string.Format("Switching Build Target to {0}", target.ToString()));
		BuildTargetGroup buildTargetGroup = BuildPipeline.GetBuildTargetGroup (target);
		EditorUserBuildSettings.SwitchActiveBuildTarget(buildTargetGroup, target);

		BuildPlayerOptions buildPlayerOptions = new BuildPlayerOptions();
		buildPlayerOptions.scenes = scenes;
		buildPlayerOptions.locationPathName = path;
		buildPlayerOptions.target = BuildTarget.Android;
		buildPlayerOptions.options = BuildOptions.None;

	    //set the internal apk version to the current unix timestamp, so this increases with every build
	    PlayerSettings.Android.bundleVersionCode = (Int32)(DateTime.UtcNow.Subtract(new DateTime(1970, 1, 1))).TotalSeconds; 
	    PlayerSettings.Android.keyaliasName = "android";
	    PlayerSettings.Android.keyaliasPass = "android";
	    PlayerSettings.Android.keystorePass = "android";
	    PlayerSettings.Android.keystoreName = Path.GetFullPath(@"./android.keystore");

		Debug.Log("Starting " + target.ToString() + " Build!");
		BuildPipeline.BuildPlayer(buildPlayerOptions);
		
	}

	[UnityEditor.MenuItem("Perform Build/WebGL Command Line Build")]
	public static void CommandLineBuildWebGL ()
	{
		BuildPlayerTarget(BuildTarget.WebGL);
	}

	[UnityEditor.MenuItem("Perform Build/WebGL")]
	public static void buildWebGL() {
		string path = "Build/webgl";
		BuildPipeline.BuildPlayer(GetBuildScenes(), path, BuildTarget.WebGL, BuildOptions.None);
	}

	[UnityEditor.MenuItem("Perform Build/iOS")]
	public static void buildiOS() {
		string path = "Build/ios";
		BuildPipeline.BuildPlayer(GetBuildScenes(), path, BuildTarget.iOS, BuildOptions.None);
	}

	[UnityEditor.MenuItem("Perform Build/Windows")]
	public static void buildWindows() {
		string path = "Build/windows/sonic.exe";
		BuildPipeline.BuildPlayer(GetBuildScenes(), path, BuildTarget.StandaloneWindows, BuildOptions.None);
	}

	[UnityEditor.MenuItem("Perform Build/Linux")]
	public static void buildLinux() {
		string path = "Build/linux/sonic.x64";
		BuildPipeline.BuildPlayer(GetBuildScenes(), path, BuildTarget.StandaloneLinux64, BuildOptions.None);
	}

	[UnityEditor.MenuItem("Perform Build/OSX")]
	public static void buildOSX() {
		string path = "Build/osx/sonic";
		BuildPipeline.BuildPlayer(GetBuildScenes(), path, BuildTarget.StandaloneOSX, BuildOptions.None);
	}

}
