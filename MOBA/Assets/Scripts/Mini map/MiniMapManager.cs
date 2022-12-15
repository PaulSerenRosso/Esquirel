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
        [SerializeField] RectTransform mapObject;

        [SerializeField] private float ratioXY;
        [SerializeField] private float ratioYX;
        [SerializeField] private Vector2 screenMapCenter;

        
          private bool updateMiniMapPos;
        private void OnDrawGizmosSelected()
        {
            Gizmos.color = Color.blue;
            Gizmos.DrawWireCube(worldMapCenter, new Vector3(worldMapSize.x , 5, worldMapSize.y));
        }

        private void OnValidate()
        {
            updateMiniMapPos = true;
          
        }

        public void UpdateMiniMapPos()
        {
            if(!updateMiniMapPos) return;
            updateMiniMapPos = false;
            ratioXY = worldMapSize.x / worldMapSize.y;
            ratioYX = worldMapSize.y / worldMapSize.x;
            mapObject.anchoredPosition = screenMapCenter;
            mapObject.SetSizeWithCurrentAnchors(RectTransform.Axis.Horizontal, ratioXY*screenMapSize);
            mapObject.SetSizeWithCurrentAnchors(RectTransform.Axis.Vertical, ratioYX*screenMapSize);
        }
        

        public void BakeStaticIcons()
        {
            
        }
       
       
    }
}