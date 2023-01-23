using UnityEngine;

public class DamagePopUp : MonoBehaviour {
    [SerializeField] private GameObject damagePopUp = null;
    [SerializeField] private Transform startPosition = null;
    [SerializeField] private Vector2 positionVariation = new Vector2(.25f,.25f);
    
    /// <summary>
    /// Spawn a damage PopUp on the player
    /// </summary>
    /// <param name="damage"></param>
    public void CreateDamagePopUp(int damage, bool lastHealthPoint) {
        GameObject popUp = !lastHealthPoint ? Instantiate(damagePopUp, startPosition) : Instantiate(damagePopUp, startPosition.position, damagePopUp.transform.rotation);
        popUp.GetComponent<DamagePopUpContainer>().Init(damage);
    }
}