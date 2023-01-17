using System;
using System.Collections;
using System.Collections.Generic;

using UnityEngine;

namespace Entities.Champion
{
    public class ChampionMoveablePrevisualisation : MonoBehaviour
    {
        public Champion champion;
        [SerializeField] private GameObject pointerDestinationMovement;

        [SerializeField] private LineRenderer agentPathLineRenderer;


        private void Start()
        {
            champion.inputController.OnMoveToCursorPos += UpdatePointerPrevisualisation;
        }

        private void UpdatePointerPrevisualisation(Vector3 position)
        {
            pointerDestinationMovement.transform.position = position;
            if (pointerDestinationMovement.activeSelf)
                pointerDestinationMovement.SetActive(false);
            pointerDestinationMovement.SetActive(true);
        }
        
        private void Update()
        {
            agentPathLineRenderer.positionCount = champion.agent.path.corners.Length;
            agentPathLineRenderer.SetPosition(0, champion.transform.position);
            for (int i = 1; i < champion.agent.path.corners.Length; i++)
            {
                Vector3 pointPosition = champion.agent.path.corners[i];
                agentPathLineRenderer.SetPosition(i, pointPosition);
            }
        }

    }
}
