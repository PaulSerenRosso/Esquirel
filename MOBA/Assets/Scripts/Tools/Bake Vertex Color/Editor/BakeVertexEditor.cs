using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(BakeVertexColorMap))]
public class BakeVertexEditor : Editor
{
    float secs = 4f;
    public override void OnInspectorGUI()
    {
        DrawDefaultInspector();
        BakeVertexColorMap bakeVertexColorMap = (BakeVertexColorMap)target;
        if (GUILayout.Button("Bake Vertex Color As PNG"))
        {
            var step = 0.1f;
            bakeVertexColorMap.GetMesh();
            for (float t = 0; t < secs; t += step)
            {
                bakeVertexColorMap.BakeVertexColor();            
            }
        }
    }
}
