//
// This file was generated by the JavaTM Architecture for XML Binding(JAXB) Reference Implementation, vJAXB 2.1.10 in JDK 6 
// See <a href="http://java.sun.com/xml/jaxb">http://java.sun.com/xml/jaxb</a> 
// Any modifications to this file will be lost upon recompilation of the source schema. 
// Generated on: 2011.04.20 at 05:42:50 PM CEST 
//


package fl;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for IfThenElse complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="IfThenElse">
 *   &lt;complexContent>
 *     &lt;extension base="{fl}Expr">
 *       &lt;sequence>
 *         &lt;element name="ifExpr" type="{fl}Expr"/>
 *         &lt;element name="thenExpr" type="{fl}Expr"/>
 *         &lt;element name="elseExpr" type="{fl}Expr"/>
 *       &lt;/sequence>
 *     &lt;/extension>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "IfThenElse", propOrder = {
    "ifExpr",
    "thenExpr",
    "elseExpr"
})
public class IfThenElse
    extends Expr
{

    @XmlElement(required = true)
    protected Expr ifExpr;
    @XmlElement(required = true)
    protected Expr thenExpr;
    @XmlElement(required = true)
    protected Expr elseExpr;

    /**
     * Gets the value of the ifExpr property.
     * 
     * @return
     *     possible object is
     *     {@link Expr }
     *     
     */
    public Expr getIfExpr() {
        return ifExpr;
    }

    /**
     * Sets the value of the ifExpr property.
     * 
     * @param value
     *     allowed object is
     *     {@link Expr }
     *     
     */
    public void setIfExpr(Expr value) {
        this.ifExpr = value;
    }

    /**
     * Gets the value of the thenExpr property.
     * 
     * @return
     *     possible object is
     *     {@link Expr }
     *     
     */
    public Expr getThenExpr() {
        return thenExpr;
    }

    /**
     * Sets the value of the thenExpr property.
     * 
     * @param value
     *     allowed object is
     *     {@link Expr }
     *     
     */
    public void setThenExpr(Expr value) {
        this.thenExpr = value;
    }

    /**
     * Gets the value of the elseExpr property.
     * 
     * @return
     *     possible object is
     *     {@link Expr }
     *     
     */
    public Expr getElseExpr() {
        return elseExpr;
    }

    /**
     * Sets the value of the elseExpr property.
     * 
     * @param value
     *     allowed object is
     *     {@link Expr }
     *     
     */
    public void setElseExpr(Expr value) {
        this.elseExpr = value;
    }

}
