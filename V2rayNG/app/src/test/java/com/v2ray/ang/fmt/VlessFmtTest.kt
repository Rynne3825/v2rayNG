package com.v2ray.ang.fmt

import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertNotNull
import org.junit.jupiter.api.Assertions.assertNull
import org.junit.jupiter.api.Test

class VlessFmtTest {

    @Test
    fun vlessWsWithoutTlsParsesCorrectly() {
        val uri = "vless://2391ddfe-6df1-4d05-9485-cdc6fd1e4a56@link.e.tiktok.com:80?path=%2Fbetltone.com&security=none&encryption=none&host=khanhdzyeuzhaolusiratxinh.betltone.com&type=ws#test-node"
        val profile = VlessFmt.parse(uri)

        assertNotNull(profile)
        profile?.let {
            assertEquals("link.e.tiktok.com", it.server)
            assertEquals("80", it.serverPort)
            assertEquals("2391ddfe-6df1-4d05-9485-cdc6fd1e4a56", it.password)
            assertEquals("none", it.method)
            assertEquals("ws", it.network)
            assertEquals("khanhdzyeuzhaolusiratxinh.betltone.com", it.host)
            assertEquals("/betltone.com", it.path)
            assertNull(it.security)
            assertEquals("test-node", it.remarks)
        }
    }

    @Test
    fun vlessWsRoundTripPreservesFields() {
        val uri = "vless://2391ddfe-6df1-4d05-9485-cdc6fd1e4a56@link.e.tiktok.com:80?path=%2Fbetltone.com&security=none&encryption=none&host=khanhdzyeuzhaolusiratxinh.betltone.com&type=ws#test-node"
        val profile = VlessFmt.parse(uri)
        assertNotNull(profile)

        val exported = "vless://${VlessFmt.toUri(profile!!)}"
        val reparsed = VlessFmt.parse(exported)
        assertNotNull(reparsed)

        assertEquals(profile.server, reparsed?.server)
        assertEquals(profile.serverPort, reparsed?.serverPort)
        assertEquals(profile.password, reparsed?.password)
        assertEquals(profile.method, reparsed?.method)
        assertEquals(profile.network, reparsed?.network)
        assertEquals(profile.host, reparsed?.host)
        assertEquals(profile.path, reparsed?.path)
    }
}
