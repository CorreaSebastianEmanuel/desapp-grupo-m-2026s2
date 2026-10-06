"""Shared identity, association and evidence contract; fixtures are real files."""
from pathlib import Path
import tempfile
import unittest

from scripts import agentflow_feature as policy

class Fixture(unittest.TestCase):
    def setUp(self):
        temporary=tempfile.TemporaryDirectory();self.addCleanup(temporary.cleanup)
        self.root=Path(temporary.name)
        self.task=self.make_task()
        self.feature=self.make_feature()
    def make_task(self, ident='TASK-017', title='Football data API adapter', status='review', extra=''):
        p=self.root/'backlog'/f'{ident}-{policy.slug(title)}.md';p.parent.mkdir(exist_ok=True)
        p.write_text(f'---\nid: {ident}\ntitle: {title}\nstatus: {status}\nactive_run: run-1\n{extra}---\n\n## Outcome\n\nSeparate delivery; merge before PR #28.\n')
        return p
    def make_feature(self, name='055-football-data-api-adapter', branch='017-football-data-api-adapter'):
        p=self.root/'specs'/name;p.mkdir(parents=True,exist_ok=True)
        (p/'spec.md').write_text(f'# Specification\n\n**Feature Branch**: `{branch}`\n' if branch is not None else '# Legacy specification\n')
        for name in ('plan.md','tasks.md'):(p/name).write_text('artifact\n')
        for name in ('qa-report.md','review-report.md'):(p/name).write_text('Report\n\nVerdict: PASS\n')
        return p
    def resolve(self, **kwargs):return policy.resolve_feature(self.root,self.task,**kwargs)

class IdentityAndResolutionTest(Fixture):
    def test_unequal_number_and_exact_branch(self):
        self.assertEqual(policy.expected_branch(self.task),'017-football-data-api-adapter')
        self.assertEqual(policy.task_for_id(self.root,'TASK-017'),self.task)
        self.assertEqual(self.resolve(head_ref='017-football-data-api-adapter').feature,self.feature)
        with self.assertRaisesRegex(ValueError,'017-football-data-api-adapter'):
            self.resolve(head_ref='017-wrong-suffix')
    def test_second_unequal_example(self):
        self.task=self.make_task('TASK-020','Player match statistics model')
        expected=self.make_feature('054-player-match-statistics','020-player-match-statistics-model')
        self.assertEqual(self.resolve().feature,expected)
    def test_metadata_only_agreement_and_legacy(self):
        self.task=self.make_task(extra='feature_directory: "specs/055-football-data-api-adapter"\n')
        self.assertEqual(self.resolve().feature,self.feature)
        (self.feature/'spec.md').write_text('# declaration free\n')
        self.assertEqual(self.resolve().feature,self.feature)
        self.task=self.make_task();self.feature.rename(self.feature.with_name('017-legacy'))
        self.assertEqual(self.resolve().feature,self.root/'specs/017-legacy')
    def test_explicit_match_beats_foreign_equal_number(self):
        self.make_feature('017-incidental','099-other')
        self.assertEqual(self.resolve().feature,self.feature)
    def test_true_absence_is_only_preproduct(self):
        import shutil
        shutil.rmtree(self.feature)
        self.assertIsNone(self.resolve(allow_missing=True))
        with self.assertRaisesRegex(ValueError,'Missing'):self.resolve()
    def test_identity_missing_duplicate_and_filename_mismatch(self):
        original=self.task.read_text()
        for key in ('id','title'):
            for text in (original.replace(f'{key}:',f'other_{key}:'),original.replace('---\n\n',f'{key}: duplicate\n---\n\n')):
                with self.subTest(key=key,text=text):
                    self.task.write_text(text)
                    with self.assertRaises(ValueError):self.resolve()
        self.task.write_text(original.replace('TASK-017','TASK-020'))
        with self.assertRaises(ValueError):policy.task_for_id(self.root,'TASK-017')
        self.task.write_text(original)
        self.make_task('TASK-999','Other',extra='id: TASK-017\n')
        with self.assertRaises(ValueError):policy.task_for_id(self.root,'TASK-017')
    def test_terminal_reports_both_gates(self):
        association=self.resolve()
        policy.require_reports(association)
        for name in ('qa-report.md','review-report.md'):
            for text in ('','Verdict: FAIL\n','Verdict: PASS\ncommentary\n','Verdict: pass\n','Verdict: PASS\nVerdict: FAIL\n'):
                with self.subTest(name=name,text=text):
                    (self.feature/name).write_text(text)
                    with self.assertRaisesRegex(ValueError,name):policy.require_reports(association)
            (self.feature/name).write_text('\n  Verdict: PASS  \n\n')
            policy.require_reports(association)

# The same rejection fixtures feed every consumer, so a bypass cannot hide behind
# a different synthetic representation of ownership.
CRITICAL_VALUES = {
    "feature_directory": "specs/099-other", "status": "blocked", "id": "TASK-099",
    "title": "Other work", "active_run": "other-run", "depends_on": "TASK-099",
}
METADATA_CASES = tuple(f"hidden:{key}:{form}" for key in CRITICAL_VALUES for form in
    ("space", "indent", "quoted", "uppercase", "duplicate", "collection", "mapping", "block", "folded", "tag", "anchor", "alias", "quote", "nested"))
COMPETING_ID_FORMS = tuple(form for whitespace in (' ', '\u00a0', '\u202f', '\u2003', '\u3000') for form in
    (f'id{whitespace}: TASK-017', f'{whitespace}id: TASK-017')) + (
        'id: task-017', 'ID: task-017', 'id: TaSk-017') + tuple(
        f'note: Other{separator}id: TASK-017' for separator in
        ('\n', '\r\n', '\r', '\v', '\f', '\x1c', '\x1d', '\x1e', '\x85', '\u2028', '\u2029'))
COMPETING_ID_CASES = tuple(f'competing-id:{i}' for i in range(len(COMPETING_ID_FORMS)))
ASSOCIATION_CASES = (
    'missing','ambiguous','ambiguous-with-metadata','duplicate-declaration','malformed-declaration',
    'heading-declaration','same-task-wrong','metadata-conflict','metadata-foreign-branch',
    'metadata-empty','metadata-absolute','metadata-traversal','metadata-nested','metadata-missing',
    'metadata-duplicate','multiple-legacy','foreign-legacy','legacy-missing-spec',
    'directory-escape','nested-alias','spec-escape','invalid-utf8-spec','duplicate-task','foreign-reports',
    'foreign-qa-report','foreign-review-report','outside-qa-report','outside-review-report',
) + METADATA_CASES + COMPETING_ID_CASES
REPORT_VALUES = (None,b'',b'Verdict: FAIL\n',b'Verdict: PASS\nVerdict: FAIL\n',b'Verdict: PASS\ncommentary\n',b'Verdict: pass\n',b'Verdict : PASS\n',b'\xff')

def poison(f, case):
    import shutil
    p=f.feature/'spec.md'
    if case.startswith('competing-id:'):
        # A different filename and canonical ID must not conceal another claim.
        f.make_task('TASK-099','Other',extra=COMPETING_ID_FORMS[int(case.split(':')[1])]+'\n')
    elif case.startswith('hidden:'):
        _,key,form=case.split(':');value=CRITICAL_VALUES[key]
        lines={"space":f"{key} : {value}", "indent":f" {key}: {value}",
               "quoted":f'"{key}": {value}', "uppercase":f"{key.upper()}: {value}",
               "duplicate":f"{key}: {value}", "collection":f"{key}: [{value}]",
               "mapping":f"{key}: {{{value}}}", "block":f"{key}: |", "folded":f"{key}: >", "tag":f"{key}: !tag {value}",
               "anchor":f"{key}: &other {value}", "alias":f"{key}: *other",
               "quote":f'{key}: "{value}', "nested":f"{key}:\n  child: {value}"}
        # Keep a valid canonical value as well: unsupported forms cannot hide a
        # contradictory key. Tests below also exercise each form alone.
        extra='feature_directory: specs/055-football-data-api-adapter\ndepends_on: none\n'
        f.task=f.make_task(extra=extra)
        f.task.write_text(f.task.read_text().replace('---\n\n',lines[form]+'\n---\n\n'))
    elif case=='missing':shutil.rmtree(f.feature)
    elif case in ('ambiguous','ambiguous-with-metadata'):
        f.make_feature('056-second')
        if case.endswith('metadata'):f.task=f.make_task(extra='feature_directory: specs/055-football-data-api-adapter\n')
    elif case=='duplicate-declaration':p.write_text(p.read_text()+'**Feature Branch**: `099-other`\n')
    elif case=='malformed-declaration':p.write_text('**Feature Branch**: 017-football-data-api-adapter\n')
    elif case=='heading-declaration':
        p.write_text('# Feature Branch: 017-football-data-api-adapter\n')
        f.task=f.make_task(extra='feature_directory: specs/055-football-data-api-adapter\n')
    elif case=='same-task-wrong':f.make_feature('056-wrong','017-wrong')
    elif case=='metadata-conflict':
        f.make_feature('056-other',None);f.task=f.make_task(extra='feature_directory: specs/056-other\n')
    elif case=='metadata-foreign-branch':
        p.write_text('**Feature Branch**: `099-other`\n');f.task=f.make_task(extra='feature_directory: specs/055-football-data-api-adapter\n')
    elif case.startswith('metadata-'):
        values={'empty':'','absolute':str(f.feature),'traversal':'specs/../055-football-data-api-adapter','nested':'specs/055-football-data-api-adapter/nested','missing':'specs/999-missing','duplicate':'specs/055-football-data-api-adapter\nfeature_directory: specs/055-football-data-api-adapter'}
        f.task=f.make_task(extra=f'feature_directory: {values[case[9:]]}\n')
    elif case in ('multiple-legacy','foreign-legacy','legacy-missing-spec'):
        shutil.rmtree(f.feature);f.feature=f.make_feature('017-legacy',None)
        if case=='multiple-legacy':f.make_feature('017-second',None)
        elif case=='foreign-legacy':(f.feature/'spec.md').write_text('**Feature Branch**: `099-other`\n')
        else:(f.feature/'spec.md').unlink()
    elif case in ('directory-escape','nested-alias'):
        f.task=f.make_task(extra='feature_directory: specs/055-football-data-api-adapter\n')
        old=f.feature;dest=f.root/'outside' if case=='directory-escape' else f.root/'specs/099-other/nested'
        dest.parent.mkdir(parents=True,exist_ok=True);shutil.move(old,dest);old.symlink_to(dest,target_is_directory=True)
    elif case=='spec-escape':
        foreign=f.make_feature('099-other','099-other');p.unlink();p.symlink_to(foreign/'spec.md')
    elif case=='invalid-utf8-spec':
        p.write_bytes(b'\xff');f.task=f.make_task(extra='feature_directory: specs/055-football-data-api-adapter\n')
    elif case=='duplicate-task':
        other=f.make_task('TASK-099','Other');other.write_text(other.read_text().replace('TASK-099','TASK-017'))
    elif case in ('foreign-reports','foreign-qa-report','foreign-review-report','outside-qa-report','outside-review-report'):
        foreign=f.make_feature('099-other','099-other')
        names=('qa-report.md','review-report.md') if case=='foreign-reports' else (case.split('-',1)[1]+'.md',)
        for name in names:
            target=foreign/name
            if case.startswith('outside-'):
                target=f.root/name;target.write_text('Verdict: PASS\n')
            report=f.feature/name;report.unlink();report.symlink_to(target)
    else:raise AssertionError(case)

class AdversarialResolutionTest(Fixture):
    def test_rejection_matrix_and_actionable_diagnostics(self):
        for case in ASSOCIATION_CASES:
            with self.subTest(case=case):
                f=Fixture();f.setUp()
                try:
                    poison(f,case)
                    with self.assertRaises(ValueError) as error:
                        association=f.resolve();policy.require_reports(association)
                    self.assertIn('TASK-017',str(error.exception))
                    if case not in METADATA_CASES + COMPETING_ID_CASES and case not in ('duplicate-task','metadata-duplicate'):self.assertIn('017-football-data-api-adapter',str(error.exception))
                finally:f.doCleanups()
    def test_contained_symlinks_aliases_and_unrelated_malformed_spec(self):
        malformed=self.make_feature('099-other','099-other');(malformed/'spec.md').write_text('**Feature Branch**: nonsense\n')
        alias=self.root/'specs/056-alias';alias.symlink_to(self.feature,target_is_directory=True)
        for name in ('spec.md','qa-report.md','review-report.md'):
            source=self.feature/name;target=self.feature/(name+'.contained');source.rename(target);source.symlink_to(target)
        association=self.resolve();self.assertEqual(association.feature,self.feature);policy.require_reports(association)
    def test_missing_duplicate_malformed_equal_number_specs_refuse_fallback(self):
        import shutil
        shutil.rmtree(self.feature);self.feature=self.make_feature('017-legacy',None)
        for text in ('**Feature Branch**: `017-wrong`\n','**Feature Branch**: 017-football-data-api-adapter\n','**Feature Branch**: `017-football-data-api-adapter`\n**Feature Branch**: `099-other`\n'):
            (self.feature/'spec.md').write_text(text)
            with self.assertRaises(ValueError):self.resolve(allow_missing=True)
    def test_pointer_and_modification_time_do_not_change_selection(self):
        import os,json
        distraction=self.make_feature('017-unrelated','099-other')
        (self.root/'.specify').mkdir()
        for value in ('specs/017-unrelated','specs/missing',None):
            pointer=self.root/'.specify/feature.json'
            if value is None:pointer.unlink(missing_ok=True)
            else:pointer.write_text(json.dumps({'feature_directory':value}))
            os.utime(distraction,(2000000000,2000000000))
            self.assertEqual(self.resolve().feature,self.feature)
    def test_unreadable_relevant_spec_and_both_reports(self):
        from unittest.mock import patch
        self.task=self.make_task(extra='feature_directory: specs/055-football-data-api-adapter\n')
        original=Path.read_bytes
        for target in (self.feature/'spec.md',self.feature/'qa-report.md',self.feature/'review-report.md'):
            def denied(path):
                if path==target:raise PermissionError('unreadable test file')
                return original(path)
            with patch.object(Path,'read_bytes',denied):
                with self.assertRaisesRegex(ValueError,'Cannot read'):
                    policy.require_reports(self.resolve())


class StrictMetadataTest(Fixture):
    def test_single_unsupported_fields_and_concealed_duplicates_refuse(self):
        for case in METADATA_CASES:
            for single in (False, True):
                with self.subTest(case=case,single=single):
                    f=Fixture();f.setUp()
                    try:
                        poison(f,case)
                        key=case.split(':')[1]
                        if single and not case.endswith(':duplicate'):
                            import re
                            f.task.write_text(re.sub(rf'(?m)^{key}:.*\n','',f.task.read_text(),count=1))
                        before=f.task.read_bytes()
                        with self.assertRaisesRegex(ValueError,r'metadata at line') as error:
                            policy.metadata(f.task)
                        self.assertIn(str(f.task),str(error.exception))
                        self.assertEqual(f.task.read_bytes(),before)
                    finally:f.doCleanups()
    def test_supported_scalars_comments_quotes_and_crlf(self):
        self.task.write_bytes(self.task.read_bytes().replace(b'title: Football data API adapter',b'title: "Football data API adapter"').replace(b'---\n\n',b"# comment\nunknown_field: '[literal]'\n\n---\n\n").replace(b'\n',b'\r\n'))
        before=self.task.read_bytes()
        self.assertEqual(policy.metadata(self.task)['unknown_field'],'[literal]')
        self.assertEqual(self.resolve().feature,self.feature)
        self.assertEqual(self.task.read_bytes(),before)
    def test_competing_alternate_id_claim_is_not_discarded(self):
        for form in (*COMPETING_ID_FORMS, ' "id": TASK-017', 'ID: TASK-017'):
            other=self.make_task('TASK-099','Other',extra=form+'\n')
            before={p:p.read_bytes() for p in self.root.rglob('*.md')}
            with self.assertRaises(ValueError):policy.metadata(other)
            with self.assertRaises(ValueError):policy.task_for_id(self.root,'TASK-017')
            self.assertEqual({p:p.read_bytes() for p in before},before)
            other.unlink()
    def test_unrelated_unsupported_identity_does_not_require_historical_repair(self):
        for form in COMPETING_ID_FORMS:
            other=self.make_task('TASK-099','Other',extra=form.replace('017','098')+'\n')
            self.assertEqual(policy.task_for_id(self.root,'TASK-017'),self.task)
            self.assertEqual(self.resolve().feature,self.feature)
            other.unlink()

class ForeignPreproductTest(Fixture):
    def test_foreign_candidates_are_missing_only_for_requested_task(self):
        self.task=self.make_task('TASK-055','New work',status='todo')
        for count in (1,2):
            if count==2:self.make_feature('055-task-feature-binding','054-agentflow-task-feature-directory-binding')
            before={p:p.read_bytes() for p in self.root.rglob('*.md')}
            self.assertIsNone(self.resolve(head_ref='055-new-work',allow_missing=True))
            with self.assertRaisesRegex(ValueError,'Missing feature ownership'):self.resolve()
            self.assertEqual({p:p.read_bytes() for p in before},before)
        legacy=self.make_feature('055-legacy',None)
        self.assertEqual(self.resolve(allow_missing=True).feature,legacy)
        self.make_feature('055-second-legacy',None)
        with self.assertRaisesRegex(ValueError,'Ambiguous'):self.resolve(allow_missing=True)
    def test_foreign_exception_does_not_hide_invalid_claims(self):
        self.task=self.make_task('TASK-055','New work',status='todo')
        candidate=self.make_feature('055-relevant',None)
        for text in ('**Feature Branch**: `055-wrong`\n','**Feature Branch**: 055-new-work\n','**Feature Branch**: `017-foreign`\n**Feature Branch**: `054-foreign`\n'):
            (candidate/'spec.md').write_text(text)
            with self.assertRaises(ValueError):self.resolve(allow_missing=True)
        (candidate/'spec.md').unlink()
        with self.assertRaises(ValueError):self.resolve(allow_missing=True)
        self.task=self.make_task('TASK-055','New work',extra='feature_directory: specs/055-football-data-api-adapter\n')
        with self.assertRaises(ValueError):self.resolve(allow_missing=True)

class FrontmatterEnumerationTest(Fixture):
    def test_scalar_separator_does_not_hide_competing_identity(self):
        other=self.make_task('TASK-099','Other --- work',extra='id : TASK-017\n')
        with self.assertRaises(ValueError):policy.task_for_id(self.root,'TASK-017')
        other.unlink()
        self.assertEqual(policy.task_for_id(self.root,'TASK-017'),self.task)
