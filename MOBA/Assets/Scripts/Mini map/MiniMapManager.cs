using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace MiniMap
{
    public class MiniMapManager : MonoBehaviour
    {
        [SerializeField] private Vector3 worldMapCenter;
        [SerializeField] Vector2 worldMapSize;
        [SerializeField] float screenMapSize;
        [SerializeField] private Vector2 screenMapCenter;
        public RectTransform mapObject;
        public GameObject iconPrefab;

        public static MiniMapManager instance;
      

        [SerializeField] Vector2 minWorldMapPosition;

        [SerializeField] public Vector2 miniMapSize;

       [SerializeField]Vector2 substractionBetweenMaxAndMinWorldPos;

        [SerializeField] private  Vector2 maxWorldMapPosition;
 
        [SerializeField] private float ratioXY;
 
        [SerializeField] private float ratioYX;
        private void Awake()
        {
            instance = this;
           UpdateMiniMapPos();
        }

        private void OnDrawGizmosSelected()
        {
            Gizmos.color = Color.blue;
            Gizmos.DrawWireCube(worldMapCenter, new Vector3(worldMapSize.x , 5, worldMapSize.y));
        }

        

        public void UpdateMiniMapPos()
        {
           
         
            ratioXY = worldMapSize.x / worldMapSize.y;
            ratioYX = worldMapSize.y / worldMapSize.x;
            mapObject.anchoredPosition = screenMapCenter;
            
            mapObject.SetSizeWithCurrentAnchors(RectTransform.Axis.Horizontal, ratioXY*screenMapSize);
            mapObject.SetSizeWithCurrentAnchors(RectTransform.Axis.Vertical, ratioYX*screenMapSize);
            minWorldMapPosition =  new Vector2(worldMapCenter.x, worldMapCenter.z) - worldMapSize/2;
            maxWorldMapPosition = (new Vector2(worldMapCenter.x, worldMapCenter.z) + worldMapSize/2);
            miniMapSize = new Vector2(ratioXY * screenMapSize, ratioYX * screenMapSize);
            substractionBetweenMaxAndMinWorldPos = maxWorldMapPosition - minWorldMapPosition;
        }


        public Vector2 GetMiniMapSize()
        {
            return miniMapSize;
        }
        public Vector2 GetMiniMapPos(Vector2 worldPos)
        {
            Vector2 ratioPos = ((worldPos)-minWorldMapPosition)/substractionBetweenMaxAndMinWorldPos;
            Debug.Log(ratioPos);
            return (ratioPos-Vector2.one/2)*miniMapSize;
        }
       
       
       
    }
}