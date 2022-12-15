using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace MiniMap
{
public class MiniMapBaseTextureCreator : MonoBehaviour
{
    [SerializeField]
    private List<MiniMapMask> miniMapMasks;

    private Texture2D currentTextureMerged;
    [SerializeField]
    private Shader maskColorApplier;
    [SerializeField]
    private Shader masksMerger;

    [SerializeField] private Color testColor;
   
    [SerializeField] private MeshFilter meshFilter;
    [SerializeField] private Texture2D testInput;
    [SerializeField] private RenderTexture testOutput;
    
    public Material material;
    public void BakeBaseTexture()
    {
        material = new Material(maskColorApplier);
        for (int i = 0; i < miniMapMasks.Count; i++)
        {
            
            Material material = new Material(maskColorApplier);
            material.SetPass(0);
//            Graphics.DrawMeshNow(meshFilter.mesh, Vector3.zero, Quaternion.identity);
          
            BakeTexture();
           // texture.ReadPixels( new Rect(0, 0, Resolution, Resolution), 0, 0);
            //RenderTexture.active = currentTexture;
            //byte[] bytes = texture.EncodeToPNG();
            //System.IO.File.WriteAllBytes(System.IO.Path.Combine(Application.dataPath, "Map Data Vertex Color.png"), bytes);
            DestroyImmediate(material);
            //DestroyImmediate(texture);
            //renderTexture.Release(); 
            
        }
        
    }
    
    void BakeTexture()
    {
        
        Material material = new Material(maskColorApplier);
        material.SetColor("_BaseColor",testColor );
        material.SetTexture("_BaseMap", testInput);
        Graphics.Blit(testInput,testOutput, material);
        Texture2D frame = new Texture2D( testOutput.width, testOutput.height );
        frame.ReadPixels( new Rect( 0, 0, testOutput.width, testOutput.height ), 0, 0, false );
        frame.Apply();
            
        byte[] bytes = frame.EncodeToPNG();
        System.IO.File.WriteAllBytes(System.IO.Path.Combine(Application.dataPath, "TestBake.png"), bytes);
        DestroyImmediate(material);
        DestroyImmediate(frame);
    }
}
}
