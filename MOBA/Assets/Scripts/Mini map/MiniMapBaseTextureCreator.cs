#if UNITY_EDITOR
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
namespace MiniMap
{
    public class MiniMapBaseTextureCreator : MonoBehaviour
    {
        [SerializeField] private List<MiniMapMask> miniMapMasks;

        [SerializeField]
        private RenderTexture baseMapTexture;

        public Material applierMaskColorMaterial;
        public Material mergerMaskMaterial;

        [SerializeField] private string texturePath;
        [SerializeField] private string textureName;
        private const string png = ".png";
        private void Start()
        {
          DisabledMaskCameras();
        }

        public void BakeBaseTexture()
        {

            EnabledMaskCameras();
            for (int i = 0; i < miniMapMasks.Count; i++)
            {
                BakeTextureWithColor(i);
            }
            MergeFirstIteration();
           MergeMasks();
           RenderTexture.active = baseMapTexture;
           Texture2D texture = new Texture2D(baseMapTexture.width, baseMapTexture.height, TextureFormat.ARGB32, false);
           texture.ReadPixels( new Rect(0, 0, baseMapTexture.width, baseMapTexture.height), 0, 0);
           byte[] bytes = texture.EncodeToPNG();
         
           System.IO.File.WriteAllBytes(System.IO.Path.Combine(Application.dataPath,texturePath+textureName+png), bytes);
           AssetDatabase.SaveAssets();
           AssetDatabase.Refresh();
        }

        private void EnabledMaskCameras()
        {
            for (int i = 0; i < miniMapMasks.Count; i++)
            {
                miniMapMasks[i].camera.enabled = true;
            }
        }
        
        private void DisabledMaskCameras()
        {
            for (int i = 0; i < miniMapMasks.Count; i++)
            {
                miniMapMasks[i].camera.enabled = false;
            }
        }
        

        private void MergeMasks()
        {
            for (int i = 2; i < miniMapMasks.Count; i++)
            {
                mergerMaskMaterial.SetTexture("_SecondTex", miniMapMasks[i].outputTexture);
                mergerMaskMaterial.SetFloat("_ToleranceStep", 0);
                mergerMaskMaterial.SetPass(0);
                Graphics.Blit(baseMapTexture, baseMapTexture, mergerMaskMaterial, 0);
                AssetDatabase.SaveAssets();
                AssetDatabase.Refresh();
            }
        }

        private void MergeFirstIteration()
        {
            mergerMaskMaterial.SetTexture("_SecondTex", miniMapMasks[1].outputTexture);
            mergerMaskMaterial.SetFloat("_ToleranceStep", 0);
            mergerMaskMaterial.SetPass(0);
            Graphics.Blit(miniMapMasks[0].outputTexture, baseMapTexture, mergerMaskMaterial, 0);
            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
        }

        void BakeTextureWithColor(int index)
        {
            applierMaskColorMaterial.SetColor("_MainColor", miniMapMasks[index].color);
            mergerMaskMaterial.SetPass(0);
            Graphics.Blit(miniMapMasks[index].inputTexture, miniMapMasks[index].outputTexture, applierMaskColorMaterial, 0);
            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
        }
        
    }
}
#endif