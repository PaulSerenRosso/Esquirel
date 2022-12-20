using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace MiniMap
{
    public class MiniMapCapturePoint : MonoBehaviour
    {
        private CapturePoint.CapturePoint capturePoint;
        [SerializeField] private Sprite neutralStateSprite;
        [SerializeField] private Sprite firstTeamStateSprite;
        [SerializeField] private Sprite secondTeamStateSprite;

        private MiniMapIcon miniMapIcon;

        public void Start()
        {
            
            StartCoroutine(AddEventToCapturePoint());
        }

        private IEnumerator AddEventToCapturePoint()
        {
            yield return new WaitForEndOfFrame();
            miniMapIcon = GetComponent<MiniMapIcon>();
            capturePoint = GetComponent<CapturePoint.CapturePoint>();
            capturePoint.neutralState.enterStateEvent += () => miniMapIcon.SetSprite(neutralStateSprite);
            capturePoint.firstTeamState.enterStateEvent += () => miniMapIcon.SetSprite(firstTeamStateSprite);
            capturePoint.secondTeamState.enterStateEvent += () => miniMapIcon.SetSprite(secondTeamStateSprite);
        }

        public void Test() => Debug.Log("bonsoir ");
    }
}