using System;
using System.Collections.Generic;
using System.Linq;
using Photon.Pun;
using UnityEngine;

namespace Entities.FogOfWar
{
    public class FogOfWarManager : MonoBehaviourPun
    {
        //Instance => talk to the group to see if that possible
        private static FogOfWarManager _instance;

        [SerializeField] private float lerpFactor;


        public static FogOfWarManager Instance
        {
            get { return _instance; }
        }

        private void Awake()
        {
            cameraFog.GetComponent<Camera>().orthographicSize = worldSize * 0.5f;
            if (_instance != null && _instance != this)
            {
                Destroy(gameObject);
            }
            else
            {
                _instance = this;
            }
        }

        /// <summary>
        /// List Of all IFogOfWarViewable for Fog of War render
        /// </summary>
        /// <param name="IFogOfWarViewable"> Interface for Entity </param>
        private List<Entity> allViewables = new List<Entity>();


        private Dictionary<Entity, List<Entity>> currentViewablesWithEntitiesShowables =
            new Dictionary<Entity, List<Entity>>();

        [Header("Camera and Scene Setup")] public Camera cameraFog;
        public List<string> sceneToRenderFog;

        public float startYPositionRay;

        [Header("Fog Of War Parameter")] [Tooltip("Color for the area where the player can't see")]
        public Color fogColor = new Color(0.25f, 0.25f, 0.25f, 1f);

        public LayerMask layerTargetFogOfWar;
        public LayerMask layerObstacleFogOfWar;


        [Tooltip("Material who is going to be render in the RenderPass")]
        public Material fogMat;

        [Tooltip("Define the size of the map to make the texture fit the RenderPass")]
        public int worldSize = 24;

        public bool worldSizeGizmos;

        //Parameter For Creating Field Of View Mesh
        public FOVSettings settingsFOV;

        private void RenderFOW()
        {
            
            foreach (var viewable in allViewables)
            {
                if (GameStates.GameStateMachine.Instance.GetPlayerTeam() == viewable.team)
                {
                    DrawFieldOfView(viewable);
                }
            }
        }

        public bool CheckEntityIsVisibleForPlayer(Entity entity)
        {
            foreach (var viewable in currentViewablesWithEntitiesShowables)
            {
                var seenShowables = viewable.Key.seenShowables;
                for (int i = seenShowables.Count - 1; i >= 0; i--)
                {
                    if (seenShowables.Contains(entity))
                    {
                        return true;

                        //Debug.Log("Remove Elements from list");
                    }
                }
            }

            return false;
        }

        /// <summary>
        /// Add Entity To the Fog Of War render
        /// </summary>
        /// <param name="viewable"></param>
        public void AddFOWViewable(Entity viewable)
        {
            allViewables.Add(viewable);
            currentViewablesWithEntitiesShowables.Add(viewable, new List<Entity>());
            viewable.meshFilterFoV.gameObject.SetActive(true);
        }

        /// <summary>
        /// Remove Entity To the Fog Of War render
        /// </summary>
        /// <param name="viewable"></param>
        public void RemoveFOWViewable(Entity viewable)
        {
            allViewables.Remove(viewable);
            currentViewablesWithEntitiesShowables.Remove(viewable);
            viewable.meshFilterFoV.gameObject.SetActive(false);
            for (int i = 0; i < viewable.seenShowables.Count; i++)
            {
                viewable.RemoveShowable(viewable.seenShowables[i]);
            }
        }


        void SetUpCurrentViewablesWithEntitiesShowables()
        {
            foreach (var viewable in currentViewablesWithEntitiesShowables)
            {
                viewable.Value.Clear();
            }
        }

        private void Update()
        {
            SetUpCurrentViewablesWithEntitiesShowables();
            RenderFOW();
            RemoveShowablesOutOfViewables();
        }

        private void RemoveShowablesOutOfViewables()
        {
            foreach (var viewable in allViewables)
            {
                var seenShowables = viewable.seenShowables;
                for (int i = seenShowables.Count - 1; i >= 0; i--)
                {
                    if (!currentViewablesWithEntitiesShowables[viewable].Contains((Entity)seenShowables[i]))
                    {
                        viewable.RemoveShowable(seenShowables[i]);
                        //Debug.Log("Remove Elements from list");
                    }
                }
            }
        }

        public void InitMesh(MeshFilter viewMeshFilter)
        {
            Mesh viewMesh = new Mesh();
            viewMeshFilter.name = "View Mesh";
            viewMeshFilter.mesh = viewMesh;
        }

        //Draw the Field of View for the Player.
        public void DrawFieldOfView(Entity entity)
        {
            int stepCount = Mathf.RoundToInt(entity.viewAngle * settingsFOV.meshResolution / 5);
            float stepAngleSize = entity.viewAngle / stepCount;
            List<Vector3> viewPoints = new List<Vector3>();
            ViewCastInfo oldViewCast = new ViewCastInfo();

            for (int i = 0; i <= stepCount; i++)
            {
                float angle = entity.viewAngle / 2 + stepAngleSize * i;
                ViewCastInfo newViewCast = ViewCastEntity(angle, entity);

                if (i > 0)
                {
                    bool edgeDstThresholdExceeded =
                        Mathf.Abs(oldViewCast.dst - newViewCast.dst) > settingsFOV.edgeDstThreshold;
                    if (oldViewCast.hit != newViewCast.hit ||
                        (oldViewCast.hit && newViewCast.hit && edgeDstThresholdExceeded))
                    {
                        EdgeInfo edge = FindEdge(oldViewCast, newViewCast, entity);
                        if (edge.pointA != Vector3.zero)
                        {
                            viewPoints.Add(edge.pointA);
                        }

                        if (edge.pointB != Vector3.zero)
                        {
                            viewPoints.Add(edge.pointB);
                        }
                    }
                }

                viewPoints.Add(newViewCast.point);
                oldViewCast = newViewCast;
            }

            entity.finalPoints = new List<Vector3>(viewPoints);
            if (entity.currentPoints.Count == 0)
                entity.currentPoints = new List<Vector3>(viewPoints);

            int vertexCount = entity.currentPoints.Count + 1;
            Vector3[] vertices = new Vector3[vertexCount];
            int[] triangles = new int[(vertexCount - 2) * 3];
            vertices[0] = Vector3.zero;
            for (int i = 0; i < vertexCount - 1; i++)
            {
                entity.currentPoints[i] =
                    Vector3.Lerp(entity.currentPoints[i], entity.finalPoints[i], Time.deltaTime * lerpFactor);
                vertices[i + 1] = entity.transform.InverseTransformPoint(entity.currentPoints[i]) +
                                  Vector3.forward * settingsFOV.maskCutawayDst;


                if (i < vertexCount - 2)
                {
                    triangles[i * 3] = 0;
                    triangles[i * 3 + 1] = i + 1;
                    triangles[i * 3 + 2] = i + 2;
                }
            }

            Mesh viewMesh = entity.meshFilterFoV.mesh;
            if (viewMesh == null)
            {
                InitMesh(entity.meshFilterFoV);
            }

            viewMesh.Clear();

            viewMesh.vertices = vertices;
            viewMesh.triangles = triangles;
            viewMesh.RecalculateNormals();
        }

        EdgeInfo FindEdge(ViewCastInfo minViewCast, ViewCastInfo maxViewCast, Entity entity)
        {
            float minAngle = minViewCast.angle;
            float maxAngle = maxViewCast.angle;
            Vector3 minPoint = Vector3.zero;
            Vector3 maxPoint = Vector3.zero;
            return new EdgeInfo(minPoint, maxPoint);
        }

        private List<RaycastHit> fieldOfViewObstacles = new List<RaycastHit>();


        ViewCastInfo ViewCastEntity(float globalAngle, Entity entity)
        {
            Vector3 dir = DirFromAngle(globalAngle, true, entity);
            RaycastHit[] hits = Physics.RaycastAll(
                new Vector3(entity.transform.position.x, startYPositionRay, entity.transform.position.z), dir,
                entity.viewRange,
                layerTargetFogOfWar);

            
            fieldOfViewObstacles.Clear();

            
            Debug.DrawRay(new Vector3(entity.transform.position.x, startYPositionRay, entity.transform.position.z), dir*
                entity.viewRange, Color.green, Time.deltaTime);

            if (hits.Length != 0)
            {
                for (int i = 0; i < hits.Length; i++)
                {
                    if (CheckHitGameObjectIsSameThanViewableEntityGameObject(entity, hits[i])) continue;
                    if (IsInLayerMask(hits[i].collider.gameObject, layerObstacleFogOfWar))
                    {
                        Bush bush = hits[i].collider.GetComponent<Bush>();
                        if (bush)
                        {
                            if (!bush.CheckBushMaskView(entity)) continue;
                        }
                        else
                        {
                            if (!entity.GetViewObstructedByObstacle()) continue;
                        }

                        fieldOfViewObstacles.Add(hits[i]);
                    }
                }

                if (fieldOfViewObstacles.Count != 0)
                {
                    RaycastHit closerHit = fieldOfViewObstacles[0];
                    for (int i = 1; i < fieldOfViewObstacles.Count; i++)
                    {
                        if (fieldOfViewObstacles[i].distance < closerHit.distance)
                        {
                            closerHit = fieldOfViewObstacles[i];
                        }
                    }

                    for (int i = 0; i < hits.Length; i++)
                    {
              
                      if (CheckHitGameObjectIsSameThanViewableEntityGameObject(entity, hits[i])) continue;
                        Entity candidateEntity = hits[i].collider.gameObject.GetComponent<Entity>();
                        if (!candidateEntity)
                        {
                            EntityFogOfWarColliderLinker entityFogOfWarColliderLinker =
                                hits[i].collider.gameObject.GetComponent<EntityFogOfWarColliderLinker>();
                            if (entityFogOfWarColliderLinker) candidateEntity = entityFogOfWarColliderLinker.GetEntity;
                        }

                        if (candidateEntity != null)
                        {
                            if (hits[i].distance <= closerHit.distance)
                            {
                                entity.AddShowable(candidateEntity);
                                ;
                                if (entity.CheckViewEntitySeeShowableEntityInBush(candidateEntity))
                                    currentViewablesWithEntitiesShowables[entity].Add(candidateEntity);
                            }
                        }
                    }
                 
                    return new ViewCastInfo(true, closerHit.point, closerHit.distance, globalAngle);
                }

                for (int i = 0; i < hits.Length; i++)
                {
                    if (CheckHitGameObjectIsSameThanViewableEntityGameObject(entity, hits[i])) continue;
                    Entity candidateEntity = hits[i].collider.gameObject.GetComponent<Entity>();
                    if (!candidateEntity)
                    {
                        EntityFogOfWarColliderLinker entityFogOfWarColliderLinker =
                            hits[i].collider.gameObject.GetComponent<EntityFogOfWarColliderLinker>();
                        if (entityFogOfWarColliderLinker) candidateEntity = entityFogOfWarColliderLinker.GetEntity;
                    }

                    if (candidateEntity != null)
                    {
                        entity.AddShowable(candidateEntity);
                        if (entity.CheckViewEntitySeeShowableEntityInBush(candidateEntity))
                            currentViewablesWithEntitiesShowables[entity].Add(candidateEntity);
                    }
                }
    
                return new ViewCastInfo(false, entity.transform.position + dir * entity.viewRange, entity.viewRange,
                    globalAngle);
            }
            return new ViewCastInfo(false, entity.transform.position + dir * entity.viewRange, entity.viewRange,
                globalAngle);
        }

        private Vector3 DirFromAngle(float angleInDegrees, bool angleIsGlobal, Entity entity)
        {
            if (!angleIsGlobal)
            {
                angleInDegrees += entity.transform.eulerAngles.y;
            }

            return new Vector3(Mathf.Sin(angleInDegrees * Mathf.Deg2Rad), 0, Mathf.Cos(angleInDegrees * Mathf.Deg2Rad));
        }

        public struct ViewCastInfo
        {
            public bool hit;
            public Vector3 point;
            public float dst;
            public float angle;

            public ViewCastInfo(bool _hit, Vector3 _point, float _dst, float _angle)
            {
                hit = _hit;
                point = _point;
                dst = _dst;
                angle = _angle;
            }
        }

        bool CheckHitGameObjectIsSameThanViewableEntityGameObject(Entity viewableEntity, RaycastHit hit)
        {
            if (viewableEntity.entityFowShowableLinker == null)
            {
                if (viewableEntity.gameObject == hit.collider.gameObject)
                    return true;
                else
                {
                    return false;
                }
            }
            if (viewableEntity.entityFowShowableLinker.gameObject == hit.collider.gameObject)
                return true;
            return false;
          
        }

        public struct EdgeInfo
        {
            public Vector3 pointA;
            public Vector3 pointB;

            public EdgeInfo(Vector3 _pointA, Vector3 _pointB)
            {
                pointA = _pointA;
                pointB = _pointB;
            }
        }

        private void OnDrawGizmos()
        {
            if (!worldSizeGizmos) return;
            Gizmos.color = Color.green;
            Gizmos.DrawWireCube(transform.position, new Vector3(worldSize * 0.9f, 10, worldSize * 0.9f));
            Gizmos.color = Color.red;
            Gizmos.DrawWireCube(transform.position, new Vector3(worldSize, 10, worldSize));
        }

        public bool IsInLayerMask(GameObject obj, LayerMask layerMask)
        {
            return ((layerMask.value & (1 << obj.layer)) > 0);
        }
    }
}


[System.Serializable]
public class FOVSettings
{
    public float meshResolution;
    public int edgeResolveIterations;
    public float edgeDstThreshold;
    public float maskCutawayDst = .1f;
}