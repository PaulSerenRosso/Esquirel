using System;
using UnityEngine;
using UnityEngine.InputSystem;

namespace Controllers
{
    public class CameraController : MonoBehaviour
    {
        //Script for the camera to follow the player
        [SerializeField] private Transform player;

        [SerializeField] private float cameraSpeed = 0.1f;

        private bool cameraLock = true;
        public static CameraController Instance;
        
        [SerializeField] private Vector3 offset;
        [SerializeField] private float lerpSpeed;
        [SerializeField] private float rotationY;
        [SerializeField] private float offsetScreenForMoveCameraFactor;
        public void Awake()
        {
            if (Instance != null && Instance != this)
            {
                DestroyImmediate(gameObject);
                return;
            }

            Instance = this;
        }

        public void LinkCamera(Transform target)
        {
            player = target;
            InputManager.PlayerMap.Camera.LockToggle.performed += OnToggleCameraLock;
        }

        public void UnLinkCamera()
        {
            player = null;
            InputManager.PlayerMap.Camera.LockToggle.performed -= OnToggleCameraLock;
        }

        /// <summary>
        /// Actions Performed on Toggle CameraLock
        /// </summary>
        /// <param name="ctx"></param>
        private void OnToggleCameraLock(InputAction.CallbackContext ctx)
        {
            if (!ctx.performed) return;
            cameraLock = !cameraLock;
      
        }

        private void LateUpdate()
        {
            UpdateCamera(Time.deltaTime);
        }

    

        private void UpdateCamera(float deltaTime)
        {
            //if the player is not null
            if (!player) return;
            Vector3 nextPos;

            //if the camera is locked the camera follows the player
            if (cameraLock)
            {
                nextPos = player.position + offset;
                transform.position = Vector3.Lerp(transform.position, nextPos, deltaTime * lerpSpeed);
            }
            else
            {
                nextPos = transform.position;

                var offsetWidth = Screen.width * offsetScreenForMoveCameraFactor;
                var offsetHeight = Screen.height * offsetScreenForMoveCameraFactor;
                if (Input.mousePosition.x >= Screen.width - offsetWidth)
                {
                    nextPos += transform.right * cameraSpeed;
                }

                if (Input.mousePosition.x <= 0 +offsetWidth)
                {
                    nextPos -= transform.right * cameraSpeed;
                }

                if (Input.mousePosition.y >= Screen.height - offsetHeight)
                {
                    nextPos += transform.forward * cameraSpeed;
                }

                if (Input.mousePosition.y <= 0 + offsetHeight)
                {
                    nextPos -= transform.forward * cameraSpeed;
                }

                nextPos.y = player.position.y + offset.y;
                var newPos = Vector3.Lerp(transform.position, nextPos, deltaTime* lerpSpeed);
                transform.position = newPos;
            }

            transform.rotation = Quaternion.Euler(transform.rotation.x, rotationY, transform.rotation.z);
        }
    }
}