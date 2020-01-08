pragma solidity ^0.6.1;

/**
 * que queremos hacer aqui:
 * 
 * necesito una address, generada a partir de su llave privada.
 * un comando web3 que pudiera hacer esto es:
 * 
 *          web3.eth.accounts.create(web3.utils.randomHex(32))
 *
 * esto devuelve un objeto JSON con la llave privada
 * podemos generar una firma con el comando:
 * 
 *          web3.eth.accounts.sign('mensaje', '0xllave priva bytes32')
 * 
 * de acuerdo a las instrucciones del token EURS, el mensaje es hash de 32 bytes de un VECTOR
 * con los siguientes parámetros:
 * 
 *          keccak256(thisAddress(), messageSenderAddress(), _to, _value, _fee, _nonce))
 * 
 * (Este formato es previo al compilador ^0.5.0, asi que me toco adaptar mi compilador)
 * 
 * donde 'thisAddress' es la funcion que devuelve la address donde se aloja el contrato EURStoken
 * y donde 'messageSenderAddress' es una funcion que devuelve al msg.sender, de tal modo que 
 * si un contrato, tal como "Credenciales" esta fungiendo como mediador en la transacción,
 * la address de este contrato sería el valor del parámetro.
 * 
 * _to es otra address y si es a donde se deben enviar los fondos, debe ser la address del
 * contrato de tesorería: Proxy.
 * 
 * _value que debe tener un valor precalculado para que la operación sea válida, es un entero positivo
 * uint256 de 32 bytes, cuyo valor ha de ser inferior al balance del signatario. 
 * Lo mismo vale para _fee, no obstante este valor debe ser cero. Es la comision
 * que le envian al msg.sender y no nos interesa que Credenciales reciba EURS que no se van a poder tocar.
 * 
 * STASIS recientemente ajusto el calculo de comisiones para que quede en cero de modo definitivo
 * ¿como hacen? me lleva a multiples especulaciones.
 * 
 * Finalmente el _nonce es un parametro de seguridad para la validación de la firma del signatario.
 * sin embargo posee un getter público en el contrato EURStoken: nonce(address) y ese es exactamente el
 * valor que hay que colocar para que la transacción se ejecute exitosamente
 * 
 *              function nonce (address _owner) public view delegatable returns (uint256) {
 *                            return nonces [_owner];
 *                                                      }
 * 
 *              donde:
 * 
 *              mapping (address => uint256) internal nonces;
 * 
 *              y la función delegatedTransfer exige:
 * 
 *              if (_nonce != nonces [_from]) return false;
 * 
 *              mas cuando la ejecucion es exitosa se instruye:
 * 
 *              nonces [_from] = _nonce + 1;
 * 
 */ 

contract Credenciales {
    
    function Verificar(
        address token,
        address buffer,
        address _to, 
        uint256 _value, 
        uint256 _fee, 
        uint256 _nonce,
        uint8 v, bytes32 r, bytes32 s) public pure returns (address Signatario) {
    
        Signatario = ecrecover(keccak256 ((abi.encodePacked( token, buffer, _to, _value, _fee, _nonce))), v, r, s);
       
        }
    
    function Hash(address token, address buffer, address _to, uint256 _value, uint256 _fee, uint256 _nonce) public pure returns (bytes32 mensaje) {
        
        
        mensaje = keccak256(abi.encodePacked(token,buffer,_to,_value,_fee,_nonce));
        
    }
    
    /**
     * Las anteriores funciones ejecutarion los calculos a la perfeccion
     * el problema que persiste es con:
     * 
     *           web3.eth.accounts.sign('mensaje', '0xllave priva bytes32')
     * 
     * posiblemente en este caso el 'mensaje' es una cadena de parámetros codificados
     * 
     * primeramente genraremos una address con su propia llave privada:
     *  
     *          web3.eth.accounts.create(web3.utils.randomHex(32))
     * 
     *resultado:
     *
     *          "address": "0x2d60B75ccD96863cc66E4867CAEB86Bc5BBF1AD8",
     *          "privateKey": "0xc2019357e91342a4411f715bf155c2e5f990424ae9a018f6dd8851ac473d678a",
     * 
     * y el mensaje resulta de codificar 3 addresses y 3 números uint256
     * 
     *          web3.eth.abi.encodeParameters(['address','address','address','uint256','uint256','uint256'], ['0xdb25f211ab05b1c97d595516f45794528a807ad8','0x001c356c0be5dd6c91ca24ef04d9e10081510682','0xa879ce660b0a41567fe33b1e329e2e9ad2b697ba','100','0','0'])
     * 
     * otra extraña opcion: decodeParameters
     * 
     *          web3.eth.abi.decodeParameters(['address','address','address','uint256','uint256','uint256'],'0x000000000000000000000000db25f211ab05b1c97d595516f45794528a807ad8000000000000000000000000001c356c0be5dd6c91ca24ef04d9e10081510682000000000000000000000000a879ce660b0a41567fe33b1e329e2e9ad2b697ba000000000000000000000000000000000000000000000000000000000000006400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000')
     *      
     * lo cual pareciera constituir el mensaje crudo del metodo.
     * 
     * la instruccion cruda pareciera ser:
     * 
     *          web3.eth.accounts.sign(web3.eth.abi.decodeParameters(['address','address','address','uint256','uint256','uint256'],'0x000000000000000000000000db25f211ab05b1c97d595516f45794528a807ad8000000000000000000000000001c356c0be5dd6c91ca24ef04d9e10081510682000000000000000000000000a879ce660b0a41567fe33b1e329e2e9ad2b697ba000000000000000000000000000000000000000000000000000000000000006400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000'),'0xc2019357e91342a4411f715bf155c2e5f990424ae9a018f6dd8851ac473d678a')
     * 
     * No obstante, el message hash esta resultando en un numero totalmente diferente.
     * 
     * quiza
     * 
     *              web3.utils.soliditySha3('0xdb25f211ab05b1c97d595516f45794528a807ad8001c356c0be5dd6c91ca24ef04d9e10081510682a879ce660b0a41567fe33b1e329e2e9ad2b697ba000000000000000000000000000000000000000000000000000000000000006400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000')
     * 
     * mucho me temo que el error pudiera estar aqui:
     * 
     * primero hay que calcular:
     * 
     *          web3.eth.abi.encodeParameters(['bytes20','bytes20','bytes20','uint256','uint256','uint256'], ['0xdb25f211ab05b1c97d595516f45794528a807ad8','0x001c356c0be5dd6c91ca24ef04d9e10081510682','0xa879ce660b0a41567fe33b1e329e2e9ad2b697ba','100','0','0'])
     * 
     * luego hay que decodificar:
     * 
     *          web3.eth.abi.decodeParameters(['bytes20','bytes20','bytes20','uint256','uint256','uint256'],'0x<rellenar aqui el codificado>')
     * 
     * finalmente se calcula la firma con la llave privada de prueba:
     * 
     *          web3.eth.accounts.sign(web3.eth.abi.decodeParameters(['bytes20','bytes20','bytes20','uint256','uint256','uint256'],'0x<rellenar aqui el codificado>'),'0xc2019357e91342a4411f715bf155c2e5f990424ae9a018f6dd8851ac473d678a')
     * 
     * Y con los resultados v, r, y s que se obtengan, ejecutar la función "Verificar" a ver si por casualidad obtenemos la address:
     *
     *          0x2d60B75ccD96863cc66E4867CAEB86Bc5BBF1AD8
     * 
     */
     
    
}
