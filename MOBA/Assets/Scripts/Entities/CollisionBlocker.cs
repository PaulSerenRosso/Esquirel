using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CollisionBlocker : MonoBehaviour
{
    public CapsuleCollider characterColliderBlocker;  
    public Collider characterCollider;

    public void SetUpBlocker()
    {
        Physics.IgnoreCollision(characterCollider, characterColliderBlocker);
    }
}
