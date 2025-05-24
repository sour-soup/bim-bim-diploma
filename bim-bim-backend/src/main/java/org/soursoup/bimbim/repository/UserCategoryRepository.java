package org.soursoup.bimbim.repository;

import org.soursoup.bimbim.entity.Category;
import org.soursoup.bimbim.entity.User;
import org.soursoup.bimbim.entity.UserCategory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserCategoryRepository extends JpaRepository<UserCategory, Long> {
    Optional<UserCategory> findByUserAndCategory(User user, Category category);
}
