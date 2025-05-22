package org.soursoup.bimbim.config;

import lombok.Getter;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;

public class JwtUserDetails implements UserDetails {

    @Getter
    private final Long id;
    private final String username;
    @Getter
    private final String roles;
    private final Collection<? extends GrantedAuthority> authorities;

    public JwtUserDetails(Long id, String username, String roles, Collection<? extends GrantedAuthority> authorities) {
        this.id = id;
        this.username = username;
        this.roles = roles;
        this.authorities = authorities;
    }

    @Override
    public String getUsername() {
        return username;
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return authorities;
    }

    @Override
    public String getPassword() {
        return null;
    }

    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        return true;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    public boolean isEnabled() {
        return true;
    }
}

