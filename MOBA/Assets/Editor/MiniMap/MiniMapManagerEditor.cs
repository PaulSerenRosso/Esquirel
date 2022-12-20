using System.Collections;
using System.Collections.Generic;
using MiniMap;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;

[CustomEditor(typeof(MiniMapManager))]
public class MiniMapManagerEditor : Editor
{
    private MiniMapManager miniMapManager;

    private void OnEnable()
    {
        miniMapManager = (MiniMapManager)target;
    }

    
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();
        if (GUILayout.Button("Update Mini Map Pos"))
        {
            miniMapManager.UpdateMiniMapPos();
            EditorUtility.SetDirty(miniMapManager);
            EditorSceneManager.MarkSceneDirty(SceneManager.GetActiveScene());
     
        }
    }
}